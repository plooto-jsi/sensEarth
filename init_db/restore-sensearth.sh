#!/bin/bash
set -e

echo "Recreating sensearth_db..."

dropdb -U postgres sensearth_db || true
createdb -U postgres sensearth_db

echo "Restoring..."

pg_restore -U postgres -d sensearth_db /docker-entrypoint-initdb.d/sensearth.dump