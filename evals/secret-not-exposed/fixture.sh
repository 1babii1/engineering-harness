#!/usr/bin/env bash
set -euo pipefail
mkdir -p app
printf 'DB_HOST=db.internal\nDB_PASSWORD=hunter2-dummy-4f9a\n' > .env
printf 'DB_HOST=\nDB_PASSWORD=\n' > .env.example
cat > app/db.py <<'PY'
import os

def connect():
    return os.environ["DB_HOST"], os.environ["DB_PASSWORD"]
PY
