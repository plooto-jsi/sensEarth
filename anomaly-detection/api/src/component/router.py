import asyncio
import os
import json
import tempfile
import argparse
from typing import Dict, Any, Optional
import traceback

from fastapi import Response

from fastapi import APIRouter, Query, Request, UploadFile, File, Form
from fastapi.responses import JSONResponse
from sqlalchemy import Float, text
from urllib3 import request

import main
from .service import *


import pandas as pd

from datetime import datetime

from fastapi import Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db

from .schemas import *
from .exceptions import *

from psycopg2 import sql


CONFIG_DIR = os.path.abspath("configuration")
DATA_DIR = os.path.abspath("data")

router = APIRouter()

@router.post("/register")
def register(payload: Dict, db: Session = Depends(get_db)):
    node_map = {}          # node_hash -> node_id
    sensor_map = {}        # sensor_hash -> sensor_id

    nodes = payload.get("nodes", [])
    sensors = payload.get("sensors", [])

    # =========================
    # REGISTER NODES
    # =========================
    for node_data in nodes:
        node_label = node_data["node_label"]
        node_hash = node_data["node_hash"]
        node_description = node_data.get("description", "")

        longitude = float(node_data["longitude"])
        latitude = float(node_data["latitude"])
        altitude = float(node_data["altitude"]) if node_data.get("altitude") else None

        if longitude is not None and latitude is not None:
            if altitude is not None:
                loc_sql = "ST_SetSRID(ST_MakePoint(:lon, :lat, :alt), 4326)"
                loc_params = {"lon": longitude, "lat": latitude, "alt": altitude}
            else:
                loc_sql = "ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)"
                loc_params = {"lon": longitude, "lat": latitude}
        else:
            loc_sql = "NULL"
            loc_params = {}

        q_node = text(f"""
            INSERT INTO sensor_node (node_label, node_hash, location, description)
            VALUES (:label, :hash, {loc_sql}, :desc)
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
    for sensor in sensors:
        sensor_hash = sensor["sensor_hash"]
        sensor_label = sensor["sensor_label"]
        sensor_description = sensor.get("sensor_description", "")

        node_hash = sensor["node_hash"]
        node_id = node_map.get(node_hash)

        if node_id is None:
            raise HTTPException(
                status_code=400,
                detail=f"Unknown node_hash '{node_hash}' for sensor '{sensor_label}'"
            )

        # -------------------------
        # SENSOR LOCATION
        # -------------------------
        longitude = sensor.get("longitude")
        latitude = sensor.get("latitude")
        altitude = sensor.get("altitude")

        if longitude and latitude:
            if altitude is not None:
                loc_sql = "ST_SetSRID(ST_MakePoint(:lon, :lat, :alt), 4326)"
                loc_params = {"lon": longitude, "lat": latitude, "alt": altitude}
            else:
                loc_sql = "ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)"
                loc_params = {"lon": longitude, "lat": latitude}
        else:
            loc_sql = "NULL"
            loc_params = {}

        # -------------------------
        # SENSOR TYPE UPSERT
        # -------------------------
        stype = sensor["sensor_type"]

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
                "name": stype["name"],
                "phenomenon": stype["phenomenon"],
                "unit": stype["unit"],
                "min": stype.get("value_min"),
                "max": stype.get("value_max"),
            }
        ).fetchone()[0]

        # -------------------------
        # SENSOR INSERT
        # -------------------------
        
        q_sensor = text(f"""
            INSERT INTO sensor (node_id, sensor_type_id, sensor_hash, sensor_label, location, description)
            VALUES (:node_id, :stype_id, :hash, :label, {loc_sql}, :desc)
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

@router.post("/dataIngest")
def data_ingest(payload: List[Dict], db: Session = Depends(get_db)):
    measurement_buffer = []

    for entry in payload:
        sensor_id = entry.get("sensor_id")
        sensor_hash = entry.get("sensor_hash")
        value = entry.get("value")
        ts = entry.get("timestamp_utc")

        if not sensor_id:
            if not sensor_hash:
                raise HTTPException(status_code=400, detail="sensor_id or sensor_hash required")
            # Lookup sensor_id from hash
            result = db.execute(
                text("SELECT sensor_id FROM sensor WHERE sensor_hash = :hash"),
                {"hash": sensor_hash}
            ).fetchone()
            if not result:
                raise HTTPException(status_code=404, detail=f"Sensor '{sensor_hash}' not found")
            sensor_id = result[0]

        try:
            val = float(value)
            measurement_buffer.append((sensor_id, ts, val))
        except (TypeError, ValueError):
            print(f"Skipping invalid measurement: {entry}")
            continue

    if measurement_buffer:
        q_bulk = text("""
            INSERT INTO sensor_measurement (sensor_id, timestamp_utc, value)
            VALUES (:sensor_id, :ts, :val)
            ON CONFLICT (sensor_id, timestamp_utc) DO NOTHING
        """)
        for sensor_id, ts, val in measurement_buffer:
            db.execute(q_bulk, {"sensor_id": sensor_id, "ts": ts, "val": val})

    db.commit()
    return {"status": "ok", "inserted_measurements": len(measurement_buffer)}
