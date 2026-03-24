import time
from requests.exceptions import RequestException
from datetime import datetime

def retry_request(func, retries=5, delay=5, backoff=2, *args, **kwargs):
    """
    Retry a request function multiple times with exponential backoff.
    func: callable (like requests.post)
    retries: number of attempts
    delay: initial delay in seconds
    backoff: multiply delay each retry
    *args, **kwargs: passed to func
    """
    current_delay = delay
    for attempt in range(1, retries + 1):
        try:
            return func(*args, **kwargs)
        except RequestException as e:
            print(f"Attempt {attempt} failed: {e}. Retrying in {current_delay}s...")
            time.sleep(current_delay)
            current_delay *= backoff
    raise ConnectionError(f"Failed after {retries} attempts")

def safe_emit(func, **kwargs):
    try:
        func(**kwargs)
    except Exception:
        pass

def normalize_altitude(payload: dict):
    """
    If altitude is described as 'kota_0', set it to 0.0
    for all nodes and sensors in the payload.
    """
    for entity_type in ("nodes", "sensors"):
        for item in payload.get(entity_type, []):
            if str(item.get("altitude", "")).lower() == "kota_0":
                label_key = "node_label" if entity_type == "nodes" else "sensor_label"
                print(f"Set altitude=0 for {entity_type[:-1]} {item.get(label_key)} based on description 'kota_0'")
                item["altitude"] = 0.0


def normalize_timestamp(ts: str) -> str:
    ts = ts.strip().replace("UTC", "").strip()

    formats = [
        "%d.%m.%Y",
        "%d.%m.%Y %H:%M",
        "%d.%m.%Y %H:%M:%S",
        "%Y-%m-%d %H:%M",
        "%Y-%m-%d %H:%M:%S",
        "%Y-%m-%dT%H:%M:%S",
    ]

    for fmt in formats:
        try:
            dt = datetime.strptime(ts, fmt)
            return dt.strftime("%Y-%m-%d %H:%M:%S")
        except ValueError:
            continue

    raise ValueError(f"Unrecognized timestamp format: {ts}")