#!/usr/bin/env bash
set -euo pipefail

DB_PATH="${DB_PATH:-/data/todos.db}"
DB_DIR="$(dirname "$DB_PATH")"

mkdir -p "$DB_DIR"

echo "[entrypoint] Using DB_PATH=$DB_PATH"

have_table() {
  sqlite3 "$DB_PATH" 'SELECT COUNT(*) FROM sqlite_master WHERE type="table" AND name="todos";' 2>/dev/null | grep -q '^1$'
}

init_db() {
  echo "[entrypoint] Initializing database schema and sample data"
  sqlite3 "$DB_PATH" <<'SQL'
PRAGMA journal_mode=WAL;
CREATE TABLE IF NOT EXISTS todos (
  id INTEGER PRIMARY KEY,
  task TEXT NOT NULL,
  status TEXT NOT NULL
);
INSERT INTO todos (task, status)
SELECT 'Write docs', 'completed'
WHERE NOT EXISTS (SELECT 1 FROM todos);
SQL
}

if [ ! -f "$DB_PATH" ] || ! have_table; then
  init_db
else
  echo "[entrypoint] Database and table exist; skipping init"
fi

exec /usr/local/bin/web

