# Monitoring for Sensearth

## Run
conda activate watchdog
python -m uvicorn monitoring.api:app --host 127.0.0.1 --port 8001 --reload
http://127.0.0.1:8001/docs#/default

## Usage

Import package as ``` from monitoring.client import emit_component_registration, emit_event, emit_metric, emit_heartbeat ```

### Examples

Registering component, its required to associate events, metrics and heartbeats with it.

```
emit_component_registration(
            name="middleware",
            instance_id="default",
            component_type="middleware",
        )
```

Events, metrics and heartbeats

```
emit_event(
    name="middleware",
    instance_id="default",
    event_type="registering_model",
    severity="INFO",
    message="Register model endpoint called",
    metadata={"model_name": request.get("model_name")}  
)

emit_metric(
    name="middleware",
    instance_id="default",
    metric_name="registered_nodes",
    value=len(node_map),
    unit="count"
)

emit_heartbeat(
        name="middleware",
        instance_id="default",
        status="OK"
    )
```