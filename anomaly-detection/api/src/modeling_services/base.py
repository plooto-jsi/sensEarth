class BaseModel:
    def __init__(self, model_name, sensor_id, conf, sliding_window_size):
        self.model_name = model_name
        self.sensor_id = sensor_id
        self.conf = conf
        self.sliding_window_size = sliding_window_size
        self.data = []

    def run(self):
        raise NotImplementedError("Subclasses should implement this method")

    def fetch_data(self):
        raise NotImplementedError("Subclasses should implement this method")

    
