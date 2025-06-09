# Multi-stage Dockerfile for Django application
# Each stage installs only the tools required for that purpose

ARG TARGET_ENV=develop

##### Build stage: compile tools only #####
FROM python:3.12-slim AS build
ARG TARGET_ENV
WORKDIR /app
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc make \
    && pip install --no-cache-dir uv \
    && rm -rf /var/lib/apt/lists/*
COPY . /app

##### SAST stage: lint and security tools #####
FROM node:18-bullseye-slim AS sast
ARG TARGET_ENV
RUN --mount=type=cache,target=/root/.npm --mount=type=cache,target=/root/.cache/pip \
    apt-get update && apt-get install -y --no-install-recommends python3 python3-pip curl && \
    npm install -g eslint && \
    pip3 install --no-cache-dir ruff && \
    if [ "$TARGET_ENV" = "release" ]; then curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | sh; fi && \
    rm -rf /var/lib/apt/lists/*
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
COPY --from=build /app/requirements.txt /app/
COPY --from=build /app/myproject /app/myproject
COPY --from=build /app/manage.py /app/
RUN --mount=type=cache,target=/root/.cache/pip pip install --no-cache-dir Django uvicorn && \
    if [ "$TARGET_ENV" = "develop" ]; then pip install --no-cache-dir debugpy; fi && \
    apt-get purge -y gcc make && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*
CMD ["uvicorn", "myproject.asgi:application", "--host", "0.0.0.0", "--port", "8000"]

##### Test runtime stage: server with pytest #####
FROM runtime AS test-runtime
ARG TARGET_ENV
RUN --mount=type=cache,target=/root/.cache/pip pip install --no-cache-dir pytest
