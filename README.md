# GPTs

See AGENTS.md for development guidelines.

## Terraform Modules

Reusable infrastructure modules are stored under `terraform/modules`.
The `webinfra` module provisions a multi-environment AWS stack including
VPC, ECS Fargate, RDS, and other components.


## Sample Full-stack Scaffold

The `infra` and `app` directories provide a minimal example of a Django + Vue.js
application deployed to AWS. Terraform files under `infra` create the AWS
resources such as ECS, ECR (for the backend), S3, and CloudFront. The `app`
directory contains Docker configurations for the Django backend and Vue
frontend. Built frontend files are uploaded to S3 for static hosting.

CI/CD workflows are defined in `.gitlab-ci.yml` and expect AWS credentials and
an S3 bucket name to be configured in GitLab CI/CD variables.

## CI Docker Image

`ci/Dockerfile` builds a job image for GitLab Runner. It contains Docker CLI,
AWS CLI, Terraform, Trivy, and gitleaks so that jobs can run security scans and
infrastructure commands via Docker-outside-of-Docker. Set `MY_CI_IMAGE` to the
published image URL in GitLab CI/CD variables.

## フロントエンドのビルド手順

Vue.js アプリは `app/frontend` ディレクトリで管理します。以下のコマンドを実行
すると、ビルド成果物を S3 バケットへ同期できます。

```bash
cd app/frontend
npm ci
npm run build
aws s3 sync dist s3://$S3_BUCKET --delete
```

`$S3_BUCKET` には Terraform で作成したバケット名を指定してください。ビルド済み
ファイルは CloudFront 経由で静的ホスティングされます。
