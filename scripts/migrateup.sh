I see the issue. The error "unable to open database file: out of memory (14)" suggests that the standard SQLite driver in goose is having trouble with your Turso database URL.

Turso databases are not local SQLite files but remote databases with a special URL format. The standard goose SQLite driver is trying to interpret your Turso URL as a local file path, which is causing this error.

Here's a different approach - let's create a custom migration script specifically for Turso databases:

```bash
#!/bin/bash

if [ -f .env ]; then
    source .env
fi

echo "Running migrations for Turso database..."

# Extract database URL for logging (without showing sensitive auth token)
DB_URL=$(echo "$DATABASE_URL" | cut -d'?' -f1)
echo "Database: $DB_URL"

# Create a temporary SQL file with all migrations
cat > /tmp/migrations.sql << 'EOF'
-- Users table
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    name TEXT NOT NULL,
    api_key TEXT UNIQUE NOT NULL
);

-- Notes table
CREATE TABLE IF NOT EXISTS notes (
    id TEXT PRIMARY KEY,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    note TEXT NOT NULL,
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE
);
EOF

# Run the migrations using curl to access the Turso HTTP API
curl -X POST "$DATABASE_URL" \
  -H "Content-Type: application/sql" \
  --data-binary @/tmp/migrations.sql

# Clean up
rm /tmp/migrations.sql

echo "Migrations completed."
```

This approach:
1. Creates a SQL file with your schema definitions
2. Uses curl to send SQL directly to the Turso database API
3. Avoids the goose tool entirely since it's having issues with Turso URLs

You can replace your existing `scripts/migrateup.sh` with this script. This should work better with Turso's remote database URLs.

Alternatively, if you want to keep using the original script structure for the assignment, you might need to establish a special connection using Turso's CLI tools, but that would require more complex authentication in your CI/CD environment.