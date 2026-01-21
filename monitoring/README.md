# Monitoring for Sensearth

## Run
conda activate watchdog
python -m uvicorn monitoring.api:app --host 127.0.0.1 --port 8001 --reload
http://127.0.0.1:8001/docs#/default