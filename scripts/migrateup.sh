#!/bin/bash

if [ -f .env ]; then
    source .env
fi

cd sql/schema
# Use the sqlite3 driver instead of "turso"
goose sqlite3 "$DATABASE_URL" up