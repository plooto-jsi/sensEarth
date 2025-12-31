from .base import BaseModel
import anomaly_detection.src.Test as AnomalyDetector

class AnomalyDetectionModel(BaseModel):
    def __init__(self, sensor_id, algorithm_name="border_check.json"):
        super().__init__(sensor_id, algorithm_name, sliding_window_size =100)

    def run(self):
        self.detector = AnomalyDetector(configuration_location=self.algorithm_name)
        self.result = self.detector.read_streaming_data(self.data)
        return self.result
    
    def fetch_data(self):
        pass
