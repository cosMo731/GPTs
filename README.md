# GPTs

See AGENTS.md for development guidelines.

## Terraform Modules

Reusable infrastructure modules are stored under `terraform/modules`. Each
component is isolated into its own module so it can be imported via
`module` blocks from environment configurations.

The `envs` directory contains one root module per environment (e.g. `prod`
and `staging`). These root modules configure the backend and provider and
instantiate the individual service modules such as ECR, ECS, RDS, Lambda,
ALB, CloudFront, and S3.

When adding a new environment, create a directory under `envs/` and supply
values via variables or CI/CD variables as described in `AGENTS.md`.
