#!/bin/bash
set -e

echo "Restoring sensearth_db..."

pg_restore -U postgres -d sensearth_db /docker-entrypoint-initdb.d/sensearth.dump