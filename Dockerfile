# syntax=docker/dockerfile:1.7
# Multi-stage Dockerfile for Django application
# Each stage installs only the tools required for that purpose

ARG TARGET_ENV=develop
ARG TFSEC_VERSION=1.28.1

##### Build stage: compile tools only #####
FROM python:3.12-slim AS build
ARG TARGET_ENV
WORKDIR /app
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc make \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY requirements.txt ./
RUN --mount=type=cache,target=/root/.cache/pip pip wheel -r requirements.txt --wheel-dir=/tmp/wheels
COPY . .

##### Node.js SAST stage #####
FROM node:18-bullseye-slim AS sast-node
RUN --mount=type=cache,target=/root/.npm npm install -g eslint
COPY --from=build /app /app

##### Python SAST stage #####
FROM python:3.12-slim AS sast-python
ARG TFSEC_VERSION
RUN --mount=type=cache,target=/root/.cache/pip pip install --no-cache-dir ruff && \
    curl -sSL https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-amd64 -o /usr/local/bin/tfsec && \
    chmod +x /usr/local/bin/tfsec
COPY --from=build /app /app

##### Test stage: install pytest when needed #####
FROM build AS test
ARG TARGET_ENV
COPY --from=build /app /app
WORKDIR /app
RUN --mount=type=cache,target=/root/.cache/pip pip install --no-cache-dir pytest

##### Runtime stage: minimal image to run Django #####
FROM python:3.12-slim AS runtime
ARG TARGET_ENV
ENV PYTHONUNBUFFERED=1
WORKDIR /app
COPY --from=build /app/requirements.txt ./
COPY --from=build /tmp/wheels /tmp/wheels
RUN --mount=type=cache,target=/root/.cache/pip pip install --no-cache-dir /tmp/wheels/* && \
    if [ "$TARGET_ENV" = "develop" ]; then pip install --no-cache-dir debugpy; fi && \
    rm -rf /tmp/wheels && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/myproject ./myproject
COPY --from=build /app/manage.py ./
ENTRYPOINT ["sh", "-c"]
CMD ["gunicorn myproject.asgi:application -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000"]

##### Test runtime stage: server with pytest #####
FROM runtime AS test-runtime
ARG TARGET_ENV
RUN --mount=type=cache,target=/root/.cache/pip pip install --no-cache-dir pytest

