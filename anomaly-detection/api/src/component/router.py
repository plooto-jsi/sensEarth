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
from sqlalchemy import Float
from urllib3 import request

import main
from .service import *


import pandas as pd

from datetime import datetime

from .models import AnomalyDetector 
from fastapi import Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db

from .schemas import *
from .exceptions import *

from psycopg2 import sql


CONFIG_DIR = os.path.abspath("configuration")
DATA_DIR = os.path.abspath("data")

router = APIRouter()

@router.post("/ingestData")
def ingest_batch(payload: list, db: Session = Depends(get_db)):
    measurement_buffer = []

    for entry in payload:
        node = entry["node"]
        sensors = entry["sensors"]

        node_id = None
        point_sql = sql.SQL("NULL")
        point_params = ()

        # UPSERT NODE
        if node:
            longitude = node.get("longitude")
            latitude = node.get("latitude")
            altitude = node.get("altitude")

            if longitude is not None and latitude is not None:
                if altitude is not None:
                    point_sql = sql.SQL("ST_SetSRID(ST_MakePoint(%s, %s, %s), 4326)")
                    point_params = (longitude, latitude, altitude)
                else:
                    point_sql = sql.SQL("ST_SetSRID(ST_MakePoint(%s, %s), 4326)")
                    point_params = (longitude, latitude)
            else:
                point_sql = sql.SQL("NULL")
                point_params = ()

            q = sql.SQL("""
                INSERT INTO sensor_node (node_label, node_serial, location, description)
                VALUES (%s, %s, {pt}, %s)
                ON CONFLICT (node_label)
                DO UPDATE SET 
                    node_serial = EXCLUDED.node_serial,
                    location = EXCLUDED.location,
                    description = EXCLUDED.description
                RETURNING node_id;
            """).format(pt=point_sql)

            params = (
                node["node_label"],
                node.get("node_serial"),
                *point_params,
                node.get("description", "")
            )
            node_id = db.execute(q, params).fetchone()[0]

        # UPSERT SENSORS
        for sensor in sensors:

            # if node was not provided, location may be defined per sensor
            longitude = sensor.get("longitude")
            latitude = sensor.get("latitude")
            altitude = sensor.get("altitude")

            if longitude is not None and latitude is not None:
                if altitude is not None:
                    spoint_sql = sql.SQL("ST_SetSRID(ST_MakePoint(%s, %s, %s), 4326)")
                    spoint_params = (longitude, latitude, altitude)
                else:
                    spoint_sql = sql.SQL("ST_SetSRID(ST_MakePoint(%s, %s), 4326)")
                    spoint_params = (longitude, latitude)
            else:
                spoint_sql = sql.SQL("NULL")
                spoint_params = ()

            # UPSERT sensor_type
            stype = sensor["type"]
            sensor_type_upsert = """
                INSERT INTO sensor_type (name, phenomenon, unit, value_min, value_max)
                VALUES (%s, %s, %s, %s, %s)
                ON CONFLICT (name, phenomenon)
                DO UPDATE SET 
                    unit = EXCLUDED.unit,
                    value_min = EXCLUDED.value_min,
                    value_max = EXCLUDED.value_max
                RETURNING sensor_type_id;
            """
            sensor_type_id = db.execute(
                sensor_type_upsert,
                (
                    stype["name"],
                    stype["phenomenon"],
                    stype["unit"],
                    stype["value_min"],
                    stype["value_max"]
                )
            ).fetchone()[0]

            # UPSERT sensor
            q_sensor = sql.SQL("""
                INSERT INTO sensor (node_id, sensor_type_id, sensor_label, location, description)
                VALUES (%s, %s, %s, {pt}, %s)
                ON CONFLICT (node_id, sensor_label)
                DO UPDATE SET sensor_type_id = EXCLUDED.sensor_type_id
                RETURNING sensor_id;
            """).format(pt=spoint_sql)

            params_sensor = (
                node_id,
                sensor_type_id,
                sensor["sensor_label"],
                *spoint_params,
                sensor.get("description", "")
            )

            sensor_id = db.execute(q_sensor, params_sensor).fetchone()[0]

            # collect bulk measurement insert
            for m in sensor["measurements"]:
                measurement_buffer.append(
                    (sensor_id, m["timestamp_utc"], m["value"])
                )

    # BULK INSERT MEASUREMENTS
    if measurement_buffer:
        args_str = ",".join(
            db.mogrify("(%s,%s,%s)", x).decode("utf-8")
            for x in measurement_buffer
        )
        db.execute(f"""
            INSERT INTO sensor_measurement (sensor_id, timestamp_utc, value)
            VALUES {args_str}
            ON CONFLICT (sensor_id, timestamp_utc) DO NOTHING;
        """)

    db.commit()


#
# @router.get("/configuration/{config_name}")
# async def detect_with_custom_config(config_name: str):
#     """
#     Endpoint for loading and returning a configuration by name, for name you provided.
#     """
#     try:
#         print("Loading config:", config_name)
#         config = load_config(config_name)
#         if not config:
#             raise ConfigFileException(config_name, "Config file is empty or missing required fields.")
#         return JSONResponse(content=config)
#     except FileNotFoundError:
#         raise ConfigFileException(config_name, "Config file not found.")
#     except ValueError as ve: 
#         raise JSONDecodeException(config_name, str(ve))
#     except ConfigFileException:
#         raise 
#     except Exception as e:
#         raise InternalServerException(str(e))

# ### Anomaly Detectors Crud operations

# @router.get("/detectors/{detector_id}/parameters")
# async def get_detector_parameters(detector_id: int, db: Session = Depends(get_db)):
#     """
#     Retrieve the anomaly detection configuration parameters for a specific detector.
#     """
#     detector = db.query(AnomalyDetector).filter(AnomalyDetector.id == detector_id).first()
#     if not detector:
#         raise DetectorNotFoundException(detector_id)

#     try:
#         if detector.config is None:
#             raise ConfigFileException(str(detector_id), "Detector config is empty.")
#         config = json.loads(detector.config)
#     except json.JSONDecodeError as e:
#         raise JSONDecodeException(str(detector_id), f"Invalid JSON in detector config: {e}")

#     if "anomaly_detection_conf" not in config:
#         raise ConfigFileException(str(detector_id), "Missing 'anomaly_detection_conf' section.")

#     return  config["anomaly_detection_conf"]

# @router.post("/detectors/{detector_id}/detect_anomaly")
# async def detect_anomaly(
#     detector_id: int,
#     timestamp: str = Query(..., description="Timestamp as float or Unix time"),
#     ftr_vector: float = Query(..., description="Feature value (single float)"),
#     db: Session = Depends(get_db)
# ):
#     detector = db.query(AnomalyDetector).filter(AnomalyDetector.id == detector_id).first()
    
#     if not detector:
#         raise DetectorNotFoundException(detector_id)  
#     if detector.status != "active":
#         raise DetectorNotActiveException(detector_id)

#     data = {
#         "timestamp": float(timestamp),
#         "ftr_vector": [ftr_vector]
#     }

#     args = argparse.Namespace(
#         config=detector.config_name,
#         data_file=False,
#         data_both=False,
#         watchdog=False,
#         test=True,
#         param_tunning=False,
#         data=data
#     )

#     try:
#         loop = asyncio.get_running_loop()
#         test_instance = await loop.run_in_executor(None, lambda: main.start_consumer(args))
#     except Exception as e:
#         print("Exception inside start_consumer:", traceback.format_exc())
#         raise ProcessingException(f"An error occurred in start_consumer: {e}")

#     return test_instance.pred_is_anomaly
    
# @router.post("/detectors/create")
# def create_detector_db(request: Dict, db: Session = Depends(get_db)):
#     """
#     Create a new anomaly detector in the database and set its initial status to 'inactive'.
#     Args:
#         request (DetectorCreateRequest): 
#             The detector creation request containing name, optional description, and configuration details. 
#             Must include either:
#                 - `config_name`: The name of an existing configuration to load, OR
#                 - `anomaly_detection_alg` and `anomaly_detection_conf`: To build a new configuration.
#     """
#     print("Creating detector with request:", request)
#     detector = create_anomaly_detector(request, db)
#     return {
#         "detector": detector
#     }

# @router.get("/detectors")
# def get_detectors(db: Session = Depends(get_db)):
#     try:
#         detectors = db.query(AnomalyDetector).all()
#         if not detectors:
#             raise DetectorNotFoundException
#     except Exception as e:
#         raise InternalServerException(f"Database error while fetching detectors: {e}")
#     return [
#         {
#             "id": detector.id,
#             "name": detector.name,
#             "description": detector.description,
#             "created_at": detector.created_at,
#             "updated_at": detector.updated_at,
#             "status": detector.status,
#             "config_name": detector.config_name,
#             "config" : detector.config
#         }
#         for detector in detectors
#     ]

# @router.get("/detectors/{detector_id}")
# def get_detector(detector_id: int, db: Session = Depends(get_db)):
#     try:
#         detector = db.query(AnomalyDetector).filter(AnomalyDetector.id == detector_id).first()
#         if not detector:
#             raise DetectorNotFoundException
#     except Exception as e:
#         raise InternalServerException(f"Database error while fetching detectors: {e}")
#     return {
#         "id": detector.id,
#         "name": detector.name,
#         "description": detector.description,
#         "created_at": detector.created_at,
#             "updated_at": detector.updated_at,
#             "status": detector.status,
#             "config_name": detector.config_name,
#             "config" : detector.config
#         }

# @router.put("/detectors/{detector_id}/{status}")
# def set_detector_status_db(detector_id: int, status: str, db: Session = Depends(get_db)):
#     """Update the status of a detector (e.g., 'active', 'inactive')."""
#     detector = set_detector_status(detector_id, status, db)
#     if not detector:
#         raise DetectorNotFoundException(detector_id)
#     return detector

# @router.put("/detectors/{detector_id}")
# def update_anomaly_detector_db(detector_id: int, request: DetectorUpdateRequest, db: Session = Depends(get_db)):
#     """Update the name and/or description of an existing anomaly detector."""
#     detector = update_anomaly_detector(db, detector_id, name=request.name, description=request.description)
#     if not detector:
#         raise DetectorNotFoundException
#     return detector

# @router.delete("/detectors/{detector_id}")
# def delete_detector_db(detector_id: int, db: Session = Depends(get_db)):
#     """Delete a specific anomaly detector and its associated config file."""
#     detector = delete_anomaly_detector(detector_id, db)
#     return detector

# @router.delete("/detectors")
# def delete_all_detectors_db(db: Session = Depends(get_db)):
#     """Delete all anomaly detectors and their associated config files."""
#     try:
#         detectors = db.query(AnomalyDetector).all()
#         if not detectors:
#             raise DetectorNotFoundException
#         delete_all_detectors(db)
#     except Exception as e:
#         raise InternalServerException(f"Database error while deleting detectors: {e}")
#     return JSONResponse(content={"status": "OK"})

# @router.get("/available_configs")
# async def get_available_configs():
#     """
#     Returns all available configuration filenames as:
#     [{"name": config.name, "filename": config.value}, ...]
#     Name isn't used for now.
#     """
#     try:
#         AvailableConfigs = create_available_configs_enum()
#         return [{"name": member.name, "filename": member.value} for member in AvailableConfigs]
#     except InternalServerException:
#         raise
#     except Exception as e:
#         raise InternalServerException(f"Failed to list available configs: {e}")


# deprecated endpoints for raw data handling  

# @router.post("/raw/upload")
# async def upload_raw_file(
#     file: UploadFile = File(...),
#     source: str = Form(...),
#     timestamp: str = Form(...)     
# ):
#     try:
#         bytes_data = await file.read()

#         object_name = f"{source}/{timestamp}_{file.filename}"

#         uploaded_path = upload_raw_data(
#             object_name=object_name,
#             data=bytes_data,
#             content_type=file.content_type
#         )

#         return {"status": "OK", "path": uploaded_path}

#     except Exception as e:
#         return JSONResponse(status_code=500, content={"error": str(e)})

# @router.get("/raw/{source}/{filename}")
# async def download_raw_file(source: str, filename: str):
#     object_name = f"{source}/{filename}"
#     file_bytes = download_raw_data(object_name)

#     if file_bytes is None:
#         raise HTTPException(404, "File not found")

#     return Response(file_bytes)

# @router.get("/raw/list")
# async def list_raw_files(source: str = ""):
#     prefix = f"{source}/" if source else ""
#     objects = list_raw_objects(prefix=prefix)
#     return {"objects": objects}

