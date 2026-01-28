from typing import Optional

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

