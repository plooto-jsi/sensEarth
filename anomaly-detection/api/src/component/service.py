import os
import json
import time
import argparse
import tempfile
from datetime import datetime, timezone, timedelta
from enum import Enum
from typing import Dict, Any, List, Optional

import numpy as np
import pandas as pd
from fastapi import APIRouter, Depends, HTTPException
from fastapi import Request, UploadFile, File, Form, Query
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from sqlalchemy import text
from psycopg2.extras import execute_values

from ..database import get_db
from ..modeling_services.anomaly_detection_model import AnomalyDetectionModel

from .models import *
from .schemas import *
from .exceptions import *
from .utils import *
from .service import *



CONFIG_DIR = os.path.abspath("configuration")
DATA_DIR = os.path.abspath("data")

def register_enteties(payload: RegisterPayload, db: Session = Depends(get_db)) -> Dict[str, Dict[str, int]]:
    """
    Registers nodes and sensors from the payload.
    Returns:
    {
        "nodes": {node_hash: node_id, ...},
        "sensors": {sensor_hash: sensor_id, ...}
    }
    """
    node_map = {}          
    sensor_map = {}        

    # =========================
    # REGISTER NODES
    # =========================
    for node_data in payload.nodes:
        node_label = node_data.node_label
        node_hash = node_data.node_hash
        longitude = node_data.longitude
        latitude = node_data.latitude
        altitude = node_data.altitude
        node_description = node_data.description

        loc_sql, loc_params = create_location_params(longitude, latitude, altitude)

        q_node = text(f"""
            INSERT INTO sensor_node (node_label, node_hash, location, description, last_seen)
            VALUES (:label, :hash, {loc_sql}, :desc, NOW())
            ON CONFLICT (node_hash)
            DO UPDATE SET
                last_seen = NOW()
            RETURNING node_id
        """)

        try:
            node_id = db.execute(
                q_node,
                {
                    "label": node_label,
                    "hash": node_hash,
                    "desc": node_description,
                    **loc_params
                }
            ).fetchone()[0]

        except Exception:
            raise HTTPException(
                status_code=409,
                detail=f"Node conflict: node_hash '{node_hash}' already exists"
            )

        node_map[node_hash] = node_id

    # =========================
    # REGISTER SENSORS
    # =========================
    for sensor_data in payload.sensors:
        # Use dot notation for Pydantic attributes
        sensor_label = sensor_data.sensor_label
        sensor_hash = sensor_data.sensor_hash
        node_hash = sensor_data.node_hash
        sensor_description = sensor_data.sensor_description

        node_id = node_map.get(node_hash)
        if node_id is None:
            raise HTTPException(
                status_code=400,
                detail=f"Unknown node_hash '{node_hash}' for sensor '{sensor_label}'"
            )

        # -------------------------
        # SENSOR LOCATION
        # -------------------------
        longitude = sensor_data.longitude
        latitude = sensor_data.latitude
        altitude = sensor_data.altitude

        loc_sql, loc_params = create_location_params(longitude, latitude, altitude)

        # -------------------------
        # SENSOR TYPE UPSERT
        # -------------------------
        stype = sensor_data.sensor_type 
        q_type = text("""
            INSERT INTO sensor_type (name, phenomenon, unit, value_min, value_max)
            VALUES (:name, :phenomenon, :unit, :min, :max)
            ON CONFLICT (name)
            DO UPDATE SET
                name = EXCLUDED.name
            RETURNING sensor_type_id
        """)

        sensor_type_id = db.execute(
            q_type,
            {
                "name": stype.name,
                "phenomenon": stype.phenomenon,
                "unit": stype.unit,
                "min": stype.value_min,
                "max": stype.value_max,
            }
        ).fetchone()[0]

        # -------------------------
        # SENSOR INSERT
        # -------------------------
        q_sensor = text(f"""
            INSERT INTO sensor (node_id, sensor_type_id, sensor_hash, sensor_label, location, description, last_seen)
            VALUES (:node_id, :stype_id, :hash, :label, {loc_sql}, :desc, NOW())
            ON CONFLICT (sensor_hash)
            DO UPDATE SET
                last_seen = NOW()
            RETURNING sensor_id
        """)

        try:
            sensor_id = db.execute(
                q_sensor,
                {
                    "node_id": node_id,
                    "stype_id": sensor_type_id,
                    "hash": sensor_hash,
                    "label": sensor_label,
                    "desc": sensor_description,
                    **loc_params
                }
            ).fetchone()[0]

        except Exception:
            raise HTTPException(
                status_code=409,
                detail=f"Sensor conflict: sensor_hash '{sensor_hash}' already exists"
            )

        sensor_map[sensor_hash] = sensor_id

    db.commit()
    return {"nodes": node_map, "sensors": sensor_map}


def ingest_measurements(payload: dataIngestPayload, db: Session = Depends(get_db)) -> Dict[str, Any]:
    measurement_buffer = []

    sensor_hashes = [
        measurement.sensor_hash
        for measurement in payload
    ]
    
    if None in sensor_hashes:
        raise HTTPException(status_code=400, detail="All entries must include 'sensor_hash'")

    if sensor_hashes:
        rows = db.execute(
            text("SELECT sensor_hash, sensor_id FROM sensor WHERE sensor_hash = ANY(:hashes)"),
            {"hashes": sensor_hashes}
        ).fetchall()
        hash_to_id = {row[0]: row[1] for row in rows}


    for measurement in payload:
        sensor_hash = measurement.sensor_hash
        ts = measurement.timestamp_utc
        value = measurement.value

        sensor_id_db = hash_to_id.get(sensor_hash)
        if sensor_id_db is None: # ID in database not found
            raise HTTPException(status_code=404, detail=f"Sensor '{sensor_hash}' not found")
        try:
            val = float(value)
            measurement_buffer.append((sensor_id_db, ts, val))
        except (TypeError, ValueError):
                print(f"Skipping invalid measurement: {measurement}")
                continue

    if measurement_buffer:
        conn = db.get_bind().raw_connection()  # get psycopg2 connection
        try:
            with conn.cursor() as cur:
                execute_values(
                    cur,
                    """
                    INSERT INTO sensor_measurement (sensor_id, timestamp_utc, value)
                    VALUES %s
                    ON CONFLICT (sensor_id, timestamp_utc)
                    DO UPDATE SET value = EXCLUDED.value
                    """,
                    measurement_buffer
                )
            conn.commit()
        finally:
            conn.close()
    db.commit()

    
    return {"status": "ok", "inserted_measurements": len(payload)}

async def model_results(payload: runModelPayload, MODEL_REGISTRY: Dict[str, Any], db: Session = Depends(get_db)) -> Dict[str, Any]:
    """
    Run specified model for a sensor with given configuration.
    Add new models to MODEL_REGISTRY.
    """
    sensor_id = payload.sensor_id
    model_type = payload.model_type
    algorithm_name = payload.algorithm_name
    sliding_window_size = payload.sliding_window_size

    if not all([sensor_id, model_type, algorithm_name]):
        raise HTTPException(status_code=400, detail="Missing required fields in payload")

    sensor_row = db.execute(
        text("SELECT sensor_id FROM sensor WHERE sensor_id = :sensor_id"),
        {"sensor_id": sensor_id}
    ).fetchone()

    if not sensor_row:
        raise HTTPException(status_code=404, detail=f"Sensor '{sensor_id}' not found")

    sensor_id = sensor_row[0]

    ModelClass = MODEL_REGISTRY.get(model_type)
    if not ModelClass:
        raise HTTPException(status_code=400, detail=f"Unsupported model type '{model_type}'")

    model_instance = ModelClass(
        sensor_id=sensor_id,
        algorithm_name=algorithm_name,
        sliding_window_size=sliding_window_size
    )

    model_instance.data = []
    sensor_data = db.execute(
        text("""
            SELECT timestamp_utc, value FROM sensor_measurement
            WHERE sensor_id = :sensor_id
            ORDER BY timestamp_utc ASC
            LIMIT :limit
        """),
        {"sensor_id": sensor_id, "limit": sliding_window_size}
    ).fetchall()

    model_instance.data_ingestion(sensor_data)
    results = model_instance.run()

    return {"status": "model run completed", "results": results}