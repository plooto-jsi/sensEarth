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
from psycopg2.extras import Json


from ..database import get_db
from ..modeling_services.anomaly_detection_model import AnomalyDetectionModel

from .models import *
from .schemas import *
from .exceptions import *
from .utils import *
from .service import *
from ..logger import logger


MODEL_REGISTRY = {
    "anomaly_detection": AnomalyDetectionModel,
}

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

def create_model(request: Dict, db: Session = Depends(get_db)):
    """
    Create a new model and optionally associate it with a sensor.

    Expected keys in request:
    - model_name: str (required)
    - model_description: str (optional)
    - model_parameters: dict (optional, stored as JSONB)
    - sensor_id_list: list[int] (optional) Allows linking model to multiple sensors.

    Returns:
    {
        "model_id": int
    }
    """
    model_name = request.get("model_name")
    model_description = request.get("model_description")
    model_parameters = request.get("model_parameters", {})
    sensor_id_list = request.get("sensor_id_list", [])
    model_type = request.get("model_type", "anomaly_detection")

    if not model_name or model_name == "":
        logger.warning("Model name is required")
        raise HTTPException(status_code=400, detail="model_name is required")

    try:
        # Create model
        q_model = text("""
            INSERT INTO model (name, description, model_type, parameters)
            VALUES (:name, :description, :model_type, :parameters)
            RETURNING model_id
        """)

        model_id = db.execute(
            q_model,
            {
                "name": model_name,
                "description": model_description,
                "model_type": model_type,
                "parameters": Json(model_parameters)
            }
        ).scalar_one()
        logger.info(f"Model '{model_name}' created with id {model_id}")

        # Optionally associate sensor

        for sensor_id in set(sensor_id_list):
            if sensor_id is not None:
                q_link = text("""
                    INSERT INTO model_sensor (model_id, sensor_id)
                    SELECT :model_id, :sensor_id
                    WHERE EXISTS (
                        SELECT 1 FROM sensor WHERE sensor_id = :sensor_id
                    )
                    ON CONFLICT DO NOTHING
                """)

                result = db.execute(
                    q_link,
                    {"model_id": model_id, "sensor_id": sensor_id}
                )

                if result.rowcount == 0:
                    logger.warning(
                        f"Sensor ID {sensor_id} not found. Model created without association."
                    )

        db.commit()
    except Exception as e:
        db.rollback()
        logger.error("Error creating model", exc_info=True)
        raise HTTPException(status_code=500, detail="Failed to create model")

    return {"model_id": model_id}


async def model_results(payload: Dict, MODEL_REGISTRY: Dict[str, Any], db: Session = Depends(get_db)) -> Dict[str, Any]:
    """
    Run specified model for a sensor with its configuration.
    Model name is UNIQUE so we can identify models by name.
    """

    model_name = payload.get("model_name")
    sensor_id_list = set(payload.get("sensor_id_list", []))
    parameters = payload.get("parameters", {})
    sliding_window_size = payload.get("sliding_window_size", 100)

    if not model_name:
        logger.error("Missing model_name in runModel payload")
        raise HTTPException(status_code=400, detail="Missing required fields in payload")

    row_model = db.execute(
        text("SELECT model_id, model_type FROM model WHERE name = :model_name"),
        {"model_name": model_name}
    ).fetchone()

    
    if not row_model:
        raise HTTPException(status_code=404, detail=f"Model '{model_name}' not found")

    model_id = row_model[0]
    model_type = row_model[1]

    ModelClass = MODEL_REGISTRY.get(model_type)
    if not ModelClass:
        raise HTTPException(status_code=400, detail=f"Unsupported model type '{model_type}'")


    logger.info(f"Model ID for '{model_name}': {model_id}, Model Type: {model_type}")

    if not sensor_id_list:
        sensor_ids = db.execute(
            text("SELECT sensor_id FROM model_sensor WHERE model_id = :model_id"),
            {"model_id": model_id}
        ).fetchall()

        sensor_id_list = set([row[0] for row in sensor_ids])

    logger.info(f"Sensor IDs associated with model '{model_name}': {sensor_id_list}")
    results = {}
    for sensor_id in sensor_id_list:
        row_sensor = db.execute(
            text("SELECT sensor_id FROM sensor WHERE sensor_id = :sensor_id"),
            {"sensor_id": sensor_id}
        ).fetchone()

        if not row_sensor:
            raise HTTPException(status_code=404, detail=f"Sensor '{sensor_id}' not found")

        sensor_id = row_sensor[0]

        
        model_instance = ModelClass(
            sensor_id=sensor_id,
            conf=parameters
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

        logger.info(f"Fetched {len(sensor_data)} measurements for sensor_id {sensor_id}")
        model_instance.data_ingestion(sensor_data)
        results[sensor_id] = model_instance.run()
        logger.info(f"Model run completed for sensor_id {sensor_id}")

    return {"status": "model run completed", "results": results}

def get_models(db: Session):
    """
    Display all registered models with their details.
    """
    rows = db.execute(
        text("SELECT model_id, name, description, model_type FROM model")
    ).fetchall()

    if not rows:
        logger.info("No models found in database")

    return rows_to_dict(rows)
    
    
def get_model(model_name: str, db: Session):
    """
    Display specific model information by name.
    """
    try:
        row = db.execute(
            text("SELECT model_id, name, description, model_type, parameters FROM model WHERE name = :model_name"),
            {"model_name": model_name}
        ).fetchone()

        if not row:
            logger.warning(f"Model '{model_name}' not found in database")
            raise HTTPException(status_code=404, detail=f"Model '{model_name}' not found)")
    except Exception as e:
        logger.error("Error fetching model", exc_info=True)
        raise HTTPException(status_code=500, detail="Failed to fetch model")

    return row_to_dict(row)

def delete_models(db: Session) -> None:
    """
    Deletes all models from the database. This will delete all models and associated configurations and results.
    """
    try: 
        q_delete_all = text("DELETE FROM model")
        db.execute(q_delete_all)
        db.commit()
        logger.info("All models removed successfully")
    except Exception as e:
        db.rollback()
        logger.error("Error removing all models", exc_info=True)
        raise HTTPException(status_code=500, detail="Failed to remove all models")
    
    return {"status": "ok", "message": "All models removed successfully"}



def delete_model(model_name: str, db: Session):
    """
    Removes specific model
    """
    try:
        q_delete = text("""
            DELETE FROM model
            WHERE name = :model_name
            RETURNING model_id
        """)
        result = db.execute(q_delete, {"model_name": model_name})
        deleted_model_id = result.scalar_one_or_none()

        if deleted_model_id is None:
            raise HTTPException(status_code=404, detail=f"Model '{model_name}' not found")

        db.commit()
        logger.info(f"Model '{model_name}' with id {deleted_model_id} removed successfully")
        return {"status": "ok", "message": f"Model '{model_name}' removed successfully"}
    except Exception as e:
        db.rollback()
        logger.error("Error removing model", exc_info=True)
        raise HTTPException(status_code=500, detail="Failed to remove model")