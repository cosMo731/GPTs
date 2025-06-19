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
with version `~> 5.0`. Because backend blocks cannot reference variables,
S3 backend settings are passed during `terraform init`:

```bash
terraform init \
  -backend-config="bucket=${TF_STATE_BUCKET}" \
  -backend-config="key=${TF_STATE_KEY}" \
  -backend-config="region=${AWS_REGION}"
```

### GitLab CI/CD Usage

In GitLab pipelines, provide backend settings and workspace names via CI/CD
variables:

```yaml
terraform:
  script:
    - terraform init \
        -backend-config="bucket=${TF_STATE_BUCKET}" \
        -backend-config="key=${TF_STATE_KEY}" \
        -backend-config="region=${AWS_REGION}" \
        -backend-config="dynamodb_table=${TF_STATE_LOCK_TABLE}"
    - terraform workspace select "${TF_WORKSPACE}" || \
      terraform workspace new "${TF_WORKSPACE}"
    - terraform plan -out=plan.tfplan
    - terraform apply -auto-approve plan.tfplan
```

Resources are automatically tagged with `Environment = ${TF_WORKSPACE}` using
`terraform.workspace`.

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

