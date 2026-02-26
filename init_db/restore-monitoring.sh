#!/bin/bash
set -e

echo "Restoring monitoring_db..."

pg_restore -U postgres -d monitoring_db /docker-entrypoint-initdb.d/monitoring.dump