from .base import BaseModel
from src.Test import Test

class AnomalyDetectionModel(BaseModel):
    def __init__(self, sensor_id, algorithm_name="border_check.json", sliding_window_size=100):
        super().__init__(sensor_id, algorithm_name, sliding_window_size)

    def run(self):
        self.detector = Test(configuration_location=self.algorithm_name)
        self.result = self.detector.read_streaming_data(self.data)
        return self.result

    def fetch_data(self):
        pass
