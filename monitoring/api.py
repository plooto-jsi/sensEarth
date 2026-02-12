from fastapi import FastAPI
from datetime import datetime
from sqlalchemy import text
from sqlalchemy.orm import Session
from fastapi import Depends, FastAPI
from service import save_component, save_event, save_metric, save_heartbeat
from logger import logger  
from database_monitoring.database import get_db 

app = FastAPI(title="WatchDog")

@app.post("/component")
def component(payload: dict, db: Session = Depends(get_db)):
    payload["timestamp"] = datetime.utcnow()
    logger.info("Component received", payload)
    save_component(payload, db)


@app.post("/heartbeat")
def heartbeat(payload: dict, db: Session = Depends(get_db)):
    payload["timestamp"] = datetime.utcnow()
    logger.info("Heartbeat received", payload)
    save_heartbeat(payload, db)

@app.post("/event")
def event(payload: dict, db: Session = Depends(get_db)):
    payload["timestamp"] = datetime.utcnow()
    logger.info("Event received", payload) 
    save_event(payload, db)

@app.post("/metric")
def metric(payload: dict, db: Session = Depends(get_db)):
    payload["timestamp"] = datetime.utcnow()
    logger.info("Metric received", payload)
    save_metric(payload, db)

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

