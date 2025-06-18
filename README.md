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

Each environment specifies the AWS provider via a `required_providers` block
with version `~> 5.0`. Backend values like bucket and key must be injected
through CI/CD variables (`TF_STATE_BUCKET`, `TF_STATE_KEY`, `AWS_REGION`).

Security best practices are implemented in the modules:

- ALB drops invalid headers and is internal by default.
- ECR enables image scanning on push.
- CloudFront supports modern TLS and accepts an optional WAF Web ACL.
- CloudFront default cache behavior forwards no cookies and disables query strings.
- Lambda functions have tracing enabled.
- RDS instances enable performance insights.
- S3 buckets create a public access block.

Run `tfsec terraform` to validate Terraform security settings.

When adding a new environment, create a directory under `envs/` and supply
values via variables or CI/CD variables as described in `AGENTS.md`.
The repository no longer includes Sphinx documentation.

