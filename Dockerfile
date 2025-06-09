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
    && apt-get install -y --no-install-recommends gcc make curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY requirements.txt ./
# Dependencies are installed from requirements.txt. Using a lock file (pip-tools/Poetry)
# would ensure deterministic builds.
RUN --mount=type=cache,target=/root/.cache/pip pip wheel -r requirements.txt --wheel-dir=/tmp/wheels \
    && find /tmp/wheels -name '*.so' -exec strip --strip-unneeded {} + || true \
    && apt-get purge -y gcc make curl && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY . .

##### Node.js SAST stage #####
FROM node:18-bullseye-slim AS sast-node
RUN --mount=type=cache,target=/root/.npm npm install -g eslint@8.56.0
COPY --from=build /app /app

##### Python SAST stage #####
FROM python:3.12-slim AS sast-python
ARG TFSEC_VERSION
RUN --mount=type=cache,target=/root/.cache/pip pip install --no-cache-dir ruff && \
    ARCH=$(uname -m); \
    case "$ARCH" in \
      aarch64) TFSEC_BIN=tfsec-linux-arm64 ;; \
      armv7l) TFSEC_BIN=tfsec-linux-armv7 ;; \
      *) TFSEC_BIN=tfsec-linux-amd64 ;; \
    esac && \
    curl -sSL https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/${TFSEC_BIN} -o /usr/local/bin/tfsec && \
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
RUN --mount=type=cache,target=/root/.cache/pip pip install --no-cache-dir --no-index --find-links=/tmp/wheels -r requirements.txt && \
    if [ "$TARGET_ENV" = "develop" ]; then pip install --no-cache-dir debugpy; fi && \
    rm -rf /tmp/wheels && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/myproject ./myproject
COPY --from=build /app/manage.py ./
ENTRYPOINT ["gunicorn", "myproject.asgi:application", "-k", "uvicorn.workers.UvicornWorker"]
CMD ["--bind", "0.0.0.0:8000"]

##### Test runtime stage: server with pytest #####
FROM runtime AS test-runtime
ARG TARGET_ENV
RUN --mount=type=cache,target=/root/.cache/pip pip install --no-cache-dir pytest

