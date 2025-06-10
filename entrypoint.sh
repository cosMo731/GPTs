#!/bin/sh
set -euo pipefail
trap 'echo "SIGTERM received, forwarding to Gunicorn"; kill -TERM "$child" 2>/dev/null' INT TERM
exec gunicorn myproject.asgi:application -k uvicorn.workers.UvicornWorker \
  --bind 0.0.0.0:8000 \
  --graceful-timeout ${GUNICORN_GRACEFUL_TIMEOUT:-90} \
  --timeout ${GUNICORN_TIMEOUT:-120} "$@" &
child=$!
wait "$child"
