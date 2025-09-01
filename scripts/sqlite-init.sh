#!/usr/bin/env bash
set -euo pipefail

# Initializes a SQLite DB with a todos table and sample data.
# Usage: bash scripts/sqlite-init.sh ./todos.db

DB_PATH=${1:-./todos.db}

echo "Creating schema in ${DB_PATH}"
sqlite3 "${DB_PATH}" <<'SQL'
PRAGMA journal_mode=WAL;
CREATE TABLE IF NOT EXISTS todos (
  id INTEGER PRIMARY KEY,
  task TEXT NOT NULL,
  status TEXT NOT NULL
);
DELETE FROM todos;
INSERT INTO todos (task, status) VALUES
  ('Write docs', 'completed'),
  ('Add tests', 'in-progress'),
  ('Refactor module', 'todo'),
  ('Ship feature', 'completed');
SQL

echo "Done. Rows:" && sqlite3 "${DB_PATH}" 'SELECT id, task, status FROM todos;'

