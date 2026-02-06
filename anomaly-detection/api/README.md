# API for Anomaly Detection Algorithms

# Run API

Move to `cd anomaly-detection`
Activate conda environment `conda activate sensearth`
Run main aplication `python -m uvicorn api.src.main:app --reload`

For debbuging use `python -m uvicorn api.src.main:app --reload --log-level debug`


Project structure based on https://github.com/zhanymkanov/fastapi-best-practices?tab=readme-ov-file#project-structure

cd anomaly-detection
conda activate sensearth
python -m uvicorn api.src.main:app --reload

# Register model example

```
{
  "model_name": "border_check_AD",
  "model_description": "Detects anomalies in sensor data",
  "model_parameters": {
    "anomaly_detection_alg": ["BorderCheck()"],
    
    "anomaly_detection_conf": [
        {
            "input_vector_size": 1,
            "warning_stages": [2.5, 0.0],
            "UL": 3.0,
            "LL": -0.4,
            "output": ["TerminalOutput()"],
            "output_conf": [{}]
        }
    ]
},
  "sensor_id_list" : [1,2,3]
}
```

# RunModel enpoint example

```

{
    "model_name": "border_check_AD",
    "sliding_window_size" : "100",
    "sensor_id_list" : [10, 20, 30] # Optional, adjust as needed
    "parameters" : {
    "anomaly_detection_alg": ["EMA()"],
    "anomaly_detection_conf": [
        {
            "input_vector_size": 1,
            "N": 3,
            "LL": -0.45,
            "UL": 0.55,
            "warning_stages": [0.3, -0.2],
            "output": ["TerminalOutput()"],
            "output_conf": [{}]
        }
    ]
}

}

```
