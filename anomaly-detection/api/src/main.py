import os
from sqlalchemy import text
from fastapi import Depends, FastAPI
import argparse
from .component.router import router
from fastapi.middleware.cors import CORSMiddleware
from .database import *
import main
import asyncio
import pandas as pd
from sqlalchemy.orm import Session
from datetime import *
import traceback
from .component.exceptions import create_exception_handlers
from .logger import logger

from monitoring.client import emit_component_registration, emit_heartbeat

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)
create_exception_handlers(app)

@app.on_event("startup")
def startup_event():
    logger.info("Starting up the Anomaly Detection API...")

    try:
        logger.info("Emitting component registration to monitoring system")
        emit_component_registration(
            name="middleware",
            instance_id="default",
            component_type="middleware",
        )
        logger.info( "Emitting initial heartbeat to monitoring system")
        emit_heartbeat(
        name="middleware",
        instance_id="default",
        status="OK"
    )
        logger.info("Component registration sent to monitoring system")
    except Exception as e:
        logger.warning(f"Error during component registration: {e}")

@app.get("/test-db")
def test(db: Session = Depends(get_db)):
    try:
        db.execute(text("SELECT 1;"))
        return {"status": "connected"}
    except Exception as e:
        return {"status": "error", "details": str(e)}





