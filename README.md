# GPTs

This repository contains sample infrastructure and CI/CD configuration.

The `.dockerignore` excludes `.gitlab-ci.yml` so CI metadata does not become
part of the Docker image. When building locally, run `docker buildx bake -f docker-bake.hcl`.
See `AGENTS.md` for development standards.
