from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class NodePayload(BaseModel):
    node_label: str
    node_hash: str
    longitude: float
    latitude: float
    altitude: Optional[float] = None
    description: Optional[str] = ""

class SensorTypePayload(BaseModel):
    name: str
    phenomenon: str
    unit: str
    value_min: Optional[float]
    value_max: Optional[float]

class SensorPayload(BaseModel):
    sensor_label: str
    sensor_hash: str
    node_hash: str
    sensor_type: SensorTypePayload
    longitude: Optional[float]
    latitude: Optional[float]
    altitude: Optional[float]
    sensor_description: Optional[str] = ""

class RegisterPayload(BaseModel):
    nodes: List[NodePayload]
    sensors: List[SensorPayload]

class MeasurementPayload(BaseModel):
    sensor_hash: str
    timestamp_utc: str  
    value: Optional[str]

class dataIngestPayload(BaseModel):
    measurements: List[MeasurementPayload]