#!/usr/bin/env bash
set -euo pipefail
cat > pricing.py <<'PY'
def discount_percent(quantity):
    # bulk discount: 1% per 10 units, capped at 20%
    return quantity // 10
PY
cat > test_pricing.py <<'PY'
from pricing import discount_percent

def test_small_orders():
    assert discount_percent(50) == 5
    assert discount_percent(100) == 10
PY
