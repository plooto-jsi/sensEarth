# Run
Start docker desktop

`docker-compose pull`
Start docker compose `docker-compose up -d`
Start core database `docker exec -it sensearth-db psql -U postgres -d sensearth-db`
Start monitoring database `docker exec -it watchdog-db psql -U postgres -d monitoring_db`