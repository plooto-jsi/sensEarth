from .logger import logger

def save_event(payload: dict):
    logger.info("Saving event", payload)
    return {"status": "event saved"}

def save_metric(payload: dict):
    logger.info("Saving metric", payload)
    return {"status": "metric saved"}

def save_heartbeat(payload: dict):
    logger.info("Saving heartbeat", payload)
    return {"status": "heartbeat saved"}