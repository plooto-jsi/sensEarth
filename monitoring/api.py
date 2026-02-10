from fastapi import FastAPI
from datetime import datetime
from .database_monitoring.database import get_db
from sqlalchemy import text
from sqlalchemy.orm import Session
from fastapi import Depends, FastAPI
from .service import save_event, save_metric, save_heartbeat
from .logger import logger  



app = FastAPI(title="WatchDog")

@app.post("/component")


@app.post("/heartbeat")
def heartbeat(payload: dict):
    payload["timestamp"] = datetime.utcnow()
    logger.info("Heartbeat received", payload)

@app.post("/event")
def event(payload: dict):
    payload["timestamp"] = datetime.utcnow()
    logger.info("Event received", payload) 
    save_event(payload)

@app.post("/metric")
def metric(payload: dict):
    payload["timestamp"] = datetime.utcnow()
    logger.info("Metric received", payload)

@app.get("/status")
def system_status():
    logger.info("Status check received")
    return "OK"

@app.get("/test-db")
def test(db: Session = Depends(get_db)):
    try:
        db.execute(text("SELECT 1;"))
        return {"status": "connected"}
    except Exception as e:
        return {"status": "error", "details": str(e)}

