#!/bin/bash

if [ -f .env ]; then
    source .env
fi

echo "Running migrations for Turso database..."

# Use the goose binary directly with SQLite driver
cd sql/schema
goose -dir . sqlite3 "$DATABASE_URL" up

echo "Migrations completed."