#!/usr/bin/env bash
set -Eeuo pipefail

enable_postgis() {
    local database="$1"

    psql --username "$POSTGRES_USER" --dbname "$database" --set ON_ERROR_STOP=1 <<-'SQL'
CREATE EXTENSION IF NOT EXISTS postgis;
SQL
}

enable_postgis template1

if [ "$POSTGRES_DB" != "template1" ]; then
    enable_postgis "$POSTGRES_DB"
fi
