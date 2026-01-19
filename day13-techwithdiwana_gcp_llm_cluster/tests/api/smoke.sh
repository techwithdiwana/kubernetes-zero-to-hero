#!/usr/bin/env bash
set -euo pipefail

echo "[API Smoke Test] Starting..."
curl -sS http://127.0.0.1:9001/healthz
echo "[API Smoke Test] OK"
