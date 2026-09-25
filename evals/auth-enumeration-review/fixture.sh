#!/usr/bin/env bash
set -euo pipefail
cat > auth.py <<'PY'
USERS = {}

def register(email, password):
    if email in USERS:
        return 409, "email already registered"
    USERS[email] = password
    return 201, "created"

def login(email, password):
    if email not in USERS:
        return 404, "unknown user"
    if USERS[email] != password:
        return 401, "wrong password"
    return 200, "ok"

def forgot_password(email):
    if email not in USERS:
        return 404, "no such account"
    return 200, "reset link sent"
PY
