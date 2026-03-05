from typing import Optional
from monitoring.client import emit_heartbeat
from sqlalchemy.orm import Session


def create_location_params(longitude: Optional[float], latitude: Optional[float], altitude: Optional[float] = None):
    """
    Returns a tuple of (SQL fragment, params dict) for inserting a PostGIS location.
    If longitude or latitude is missing, returns ("NULL", {}).
    """
    if longitude is not None and latitude is not None:
        if altitude is not None:
            return "ST_SetSRID(ST_MakePoint(:lon, :lat, :alt), 4326)", {"lon": longitude, "lat": latitude, "alt": altitude}
        return "ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)", {"lon": longitude, "lat": latitude}
    return "NULL", {}

def rows_to_dict(rows):
    return [dict(r._mapping) for r in rows]
    
def row_to_dict(row):
    return dict(row._mapping) if row else None

def db_healthcheck(db: Session):
    try:
        db.execute(text("SELECT 1;"))
        emit_heartbeat(name="database", instance_id="default", status="OK")

        return {"status": "connected"}
    except Exception as e:
        emit_heartbeat(name="database", instance_id="default", status="FAIL")
        
        return {"status": "error", "details": str(e)}
