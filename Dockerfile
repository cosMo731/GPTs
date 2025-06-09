# Multi-stage Dockerfile for Django application
# Each stage installs only the tools required for that purpose

ARG TARGET_ENV=develop

##### Build stage: compile tools and uv #####
FROM python:3.12-slim AS build
ARG TARGET_ENV
WORKDIR /app
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc make \
    && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir uv
COPY . /app

##### SAST stage: lint and security tools #####
FROM build AS sast
ARG TARGET_ENV
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get update && apt-get install -y nodejs curl && \
    npm install -g eslint && \
    pip install --no-cache-dir ruff && \
    if [ "$TARGET_ENV" = "release" ]; then curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | sh; fi && \
    rm -rf /var/lib/apt/lists/*

##### Test stage: install pytest when needed #####
FROM build AS test
ARG TARGET_ENV
COPY --from=build /app /app
WORKDIR /app
RUN pip install --no-cache-dir pytest

##### Runtime stage: minimal image to run Django #####
FROM python:3.12-slim AS runtime
ARG TARGET_ENV
ENV PYTHONUNBUFFERED=1
WORKDIR /app
COPY --from=build /app /app
RUN pip install --no-cache-dir Django uvicorn && \
    if [ "$TARGET_ENV" = "develop" ]; then pip install --no-cache-dir debugpy; fi && \
    apt-get purge -y gcc make && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*
CMD ["uvicorn", "myproject.asgi:application", "--host", "0.0.0.0", "--port", "8000"]

##### Test runtime stage: server with pytest #####
FROM runtime AS test-runtime
ARG TARGET_ENV
RUN pip install --no-cache-dir pytest
