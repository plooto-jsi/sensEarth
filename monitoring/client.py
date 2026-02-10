import requests, threading

WATCHDOG_URL = "http://watchdog-api:8001"

def _send(path, payload):
    try:
        requests.post(f"{WATCHDOG_URL}{path}", json=payload, timeout=0.05)
    except:
        pass 

def emit_heartbeat(name: str, instance_id: str, status: str = "OK", metadata: dict | None = None,):
    threading.Thread(
        target=_send,
        args=(
            "/heartbeat",
            {
                "name": name,
                "instance_id": instance_id,
                "status": status,
                "metadata": metadata or {},
            },
        ),
        daemon=True,
    ).start()

def emit_event(name: str, instance_id: str, event_type: str, severity: str = "INFO", message: str | None = None, metadata: dict | None = None,):
    threading.Thread(
        target=_send,
        args=(
            "/event",
            {
                "name": name,
                "instance_id": instance_id,
                "event_type": event_type,
                "severity": severity,
                "message": message,
                "metadata": metadata or {},
            },
        ),
        daemon=True,
    ).start()

def emit_metric(name: str, instance_id: str, metric_name: str, value: float, unit: str | None = None, metadata: dict | None = None,):
    threading.Thread(
        target=_send,
        args=(
            "/metric",
            {
                "name": name,
                "instance_id": instance_id,
                "metric_name": metric_name,
                "value": value,
                "unit": unit,
                "metadata": metadata or {},
            },
        ),
        daemon=True,
    ).start()

def emit_component_registration(name: str, instance_id: str, component_type: str = "other",):
    threading.Thread(
        target=_send,
        args=(
            "/component",
            {
                "name": name,
                "instance_id": instance_id,
                "type": component_type,
            },
        ),
        daemon=True,
    ).start()
