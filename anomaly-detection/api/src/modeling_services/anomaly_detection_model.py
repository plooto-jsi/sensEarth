from .base import BaseModel
from src.Test import Test

class AnomalyDetectionModel(BaseModel):
    def __init__(self, sensor_id, conf, sliding_window_size=100):
        super().__init__(sensor_id, conf, sliding_window_size)

    def data_ingestion(self, measurements):
        self.data = [
        {
            "timestamp": float(m.timestamp_utc.timestamp()) / 86400.0, # Convert to days since epoch
            "ftr_vector": [float(m.value)],
        }
        for m in measurements
        ]

    def run(self):
        self.detector = Test(conf=self.conf)
        self.result = self.detector.read_streaming_data(self.data)
        return self.result

    def fetch_data(self):
        pass
