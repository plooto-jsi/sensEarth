import requests, threading

WATCHDOG_URL = "http://watchdog-api:8001"

def _send(path, payload):
    try:
        requests.post(f"{WATCHDOG_URL}{path}", json=payload, timeout=0.05)
    except:
        pass 

def emit_heartbeat(component, instance_id=None):
    threading.Thread(target=_send, args=(
        "/heartbeat",
        {"component": component, "instance_id": instance_id}
    )).start()

def emit_event(component, name, status, metadata=None):
    threading.Thread(target=_send, args=(
        "/event",
        {
            "component": component,
            "event": name,
            "status": status,
            "metadata": metadata or {}
        }
    )).start()

def emit_metric(component, name, value):
    threading.Thread(target=_send, args=(
        "/metric",
        {"component": component, "metric": name, "value": value}
    )).start()
