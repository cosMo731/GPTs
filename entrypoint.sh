#!/bin/sh
exec gunicorn myproject.asgi:application -k uvicorn.workers.UvicornWorker \
  --bind 0.0.0.0:8000 \
  --graceful-timeout ${GUNICORN_GRACEFUL_TIMEOUT:-90} \
  --timeout ${GUNICORN_TIMEOUT:-120} "$@"
