# Run
Start docker desktop

`docker-compose pull`

Start docker compose `docker-compose up -d`

Start core database `docker exec -it sensearth-db psql -U postgres -d sensearth-db`

Start monitoring database `docker exec -it watchdog-db psql -U postgres -d monitoring_db`

# Export data for portability 
Sensearth db
```bash 
docker exec sensearth-db pg_dump -U postgres -Fc sensearth_db > init_db/sensearth.dump
```

Watchdog db
```bash 
docker exec watchdog-db pg_dump -U postgres -Fc monitoring_db > init_db/monitoring.dump
```

