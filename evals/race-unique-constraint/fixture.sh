#!/usr/bin/env bash
set -euo pipefail
cat > signup.py <<'PY'
import sqlite3

SCHEMA = "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, username TEXT NOT NULL)"

def register(conn: sqlite3.Connection, username: str) -> int:
    conn.execute(SCHEMA)
    row = conn.execute("SELECT 1 FROM users WHERE username = ?", (username,)).fetchone()
    if row:
        return 409
    conn.execute("INSERT INTO users(username) VALUES (?)", (username,))
    conn.commit()
    return 201
PY
