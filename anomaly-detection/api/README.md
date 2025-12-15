#run app

conda activate sensearth
python -m uvicorn api.src.main:app --reload

##For debbuging use 
python -m uvicorn api.src.main:app --reload --log-level debug

API for Anomaly Detection Algorithms


Project structure based on https://github.com/zhanymkanov/fastapi-best-practices?tab=readme-ov-file#project-structure

TEMPLATES
https://themewagon.github.io/DashboardKit

echo api
https://www.youtube.com/watch?v=-oCHXAUwZt0