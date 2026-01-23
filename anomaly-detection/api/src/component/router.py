import os
from typing import Dict, Any, List
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException
from fastapi import Request, UploadFile, File, Form, Query
from fastapi.responses import JSONResponse

from sqlalchemy.orm import Session
from sqlalchemy import text
from psycopg2.extras import execute_values

import pandas as pd

from ..database import get_db
from ..modeling_services.anomaly_detection_model import AnomalyDetectionModel

from .schemas import *
from .exceptions import *
from .service import *
from .utils import *


CONFIG_DIR = os.path.abspath("configuration")
DATA_DIR = os.path.abspath("data")

router = APIRouter()

MODEL_REGISTRY = {
    "anomaly_detection": AnomalyDetectionModel,
}

@router.post("/register")
def register(payload: RegisterPayload, db: Session = Depends(get_db)) -> Dict[str, Dict[str, int]]:
    """
    Returns a mapping of node_hash to node_id and sensor_hash to sensor_id.
    Registers nodes and sensors from the payload.
    Returns:
    {
        "nodes": {node_hash: node_id, ...},
        "sensors": {sensor_hash: sensor_id, ...}
    }
    """

    if not payload:
        raise HTTPException(status_code=400, detail="Empty payload")

    return register_enteties(payload, db)


@router.post("/dataIngest")
def data_ingest(payload: List[MeasurementPayload], db: Session = Depends(get_db)) -> Dict[str, Any]:
    """
    MeasurementPayload Pydantic model with:
    - sensor_hash: str
    - timestamp_utc: str
    - value: str
    """
    print("Data ingest called with", len(payload), "measurements")
    
    if not payload:
        raise HTTPException(status_code=400, detail="Empty payload")

    return ingest_measurements(payload, db)

@router.post("/runModel")
async def run_model(payload: runModelPayload, db: Session = Depends(get_db)) -> Dict[str, Any]:
    """
    Run specified model for a sensor with given configuration.
    Add new models to MODEL_REGISTRY.
    """
    return await model_results(payload, MODEL_REGISTRY, db)