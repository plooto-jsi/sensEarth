from .base import BaseModel
from src.Test import Test
from monitoring.client import emit_component_registration, emit_heartbeat, emit_event, emit_metric

class AnomalyDetectionModel(BaseModel):
    def __init__(self, model_name, sensor_id, conf, sliding_window_size=100):
        super().__init__(model_name, sensor_id, conf, sliding_window_size)

        emit_component_registration(name=model_name, instance_id="default", component_type="model")
    
        emit_heartbeat(
            name=model_name,
            instance_id="default",
            status="INITIALIZED"
        )

    def data_ingestion(self, measurements):
        self.data = [
        {
            "timestamp": float(m.timestamp_utc.timestamp()) / 86400.0, # Convert to days since epoch
            "ftr_vector": [float(m.value)],
        }
        for m in measurements
        ]

        emit_metric(
            name=self.model_name,
            instance_id="default",
            metric_name="ingested_measurements",
            value=len(self.data),
            unit="count"
        )

        emit_event(
            name=self.model_name,
            instance_id="default",
            event_type="data_ingested",
            severity="INFO",
            message=f"Ingested {len(self.data)} measurements"
        )

    def run(self):
        emit_heartbeat(
            name=self.model_name,
            instance_id="default",
            status="OK"
        )

        try:
            self.detector = Test(conf=self.conf)
            self.result = self.detector.read_streaming_data(self.data)

            emit_metric(
                name=self.model_name,
                instance_id="default",
                metric_name="processed_measurements",
                value=len(self.data),
                unit="count"
            )

            emit_event(
                name=self.model_name,
                instance_id="default",
                event_type="processing_completed",
                severity="INFO",
                message=f"Processed {len(self.data)} measurements"
            )

            emit_heartbeat(
                name=self.model_name,
                instance_id="default",
                status="OK"
            )

            return self.result

        except Exception as e:
            emit_heartbeat(
                name=self.model_name,
                instance_id="default",
                status="FAIL"
            )

            emit_event(
                name=self.model_name,
                instance_id="default",
                event_type="processing_failed",
                severity="ERROR",
                message=str(e)
            )

            raise

    def fetch_data(self):
        pass
