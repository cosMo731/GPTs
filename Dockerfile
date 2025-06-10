# syntax=docker/dockerfile:1.7
# Multi-stage Dockerfile for Django application
# Stage layout: deps -> build -> sast-node -> sast-python -> test -> runtime -> test-runtime

ARG TARGET_ENV=develop
ARG MY_CI_IMAGE
ARG TFSEC_VERSION=1.28.1

##### deps stage: build dependency wheels #####
FROM python:3.12-slim AS deps
WORKDIR /app
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc make curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY requirements.txt ./
RUN --mount=type=cache,target=/root/.cache/pip pip wheel -r requirements.txt --wheel-dir=/tmp/wheels \
    && find /tmp/wheels -name '*.so' -exec strip --strip-unneeded {} + || true \
    && apt-get purge -y gcc make curl && apt-get clean && rm -rf /var/lib/apt/lists/*

##### build stage: install uv and application code #####
FROM python:3.12-slim AS build
WORKDIR /app
COPY --from=deps /tmp/wheels /tmp/wheels
# Build stage installs application code
COPY myproject ./myproject
COPY manage.py ./

##### Node.js SAST stage #####
FROM node:18-bullseye-slim AS sast-node
RUN --mount=type=cache,target=/root/.npm npm install -g eslint@8.56.0
COPY --from=build /app /app

##### Python SAST stage #####
FROM python:3.12-slim AS sast-python
ARG TFSEC_VERSION
ARG TFSEC_SHA256
RUN --mount=type=cache,target=/root/.cache/pip pip install --no-cache-dir ruff && \
    ARCH=$(uname -m); \
    case "$ARCH" in \
      aarch64) TFSEC_BIN=tfsec-linux-arm64 ;; \
      armv7l) TFSEC_BIN=tfsec-linux-armv7 ;; \
      *) TFSEC_BIN=tfsec-linux-amd64 ;; \
    esac && \
    curl -sSL https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/${TFSEC_BIN} -o /usr/local/bin/tfsec && \
    if [ -n "$TFSEC_SHA256" ]; then echo "$TFSEC_SHA256  /usr/local/bin/tfsec" | sha256sum -c -; fi && \
    chmod +x /usr/local/bin/tfsec
COPY --from=build /app /app

##### test stage: pytest only #####
FROM build AS test
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir /tmp/wheels/* && \
    pip install --no-cache-dir pytest

##### runtime stage: minimal image #####
FROM python:3.12-slim AS runtime
ENV PYTHONUNBUFFERED=1 \
    GUNICORN_TIMEOUT=120 \
    GUNICORN_GRACEFUL_TIMEOUT=90
WORKDIR /app
COPY --from=deps /tmp/wheels /tmp/wheels
RUN --mount=type=cache,target=/root/.cache/pip pip install /tmp/wheels/* && \
    pip install --no-cache-dir uvicorn && \
    rm -rf /tmp/wheels && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY myproject ./myproject
COPY manage.py ./
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD []

##### test runtime stage #####
FROM runtime AS test-runtime
RUN --mount=type=cache,target=/root/.cache/pip pip install --no-cache-dir pytest ruff
