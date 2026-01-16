from fastapi import FastAPI
from datetime import datetime
from .database_monitoring.database import get_db
from sqlalchemy import text
from sqlalchemy.orm import Session
from fastapi import Depends, FastAPI



app = FastAPI(title="WatchDog")

@app.post("/heartbeat")
def heartbeat(payload: dict):
    payload["timestamp"] = datetime.utcnow()

@app.post("/event")
def event(payload: dict):
    payload["timestamp"] = datetime.utcnow()

@app.post("/metric")
def metric(payload: dict):
    payload["timestamp"] = datetime.utcnow()

@app.get("/status")
def system_status():
    return # compute_system_health()

@app.get("/test-db")
def test(db: Session = Depends(get_db)):
    try:
        db.execute(text("SELECT 1;"))
        return {"status": "connected"}
    except Exception as e:
        return {"status": "error", "details": str(e)}

