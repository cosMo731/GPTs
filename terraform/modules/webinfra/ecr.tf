# ECR repository with image scanning enabled.
module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 1.6"

  repository_name         = "${var.prefix}-app"
  create_repository       = true
  repository_force_delete = true
  image_scanning_configuration = {
    scan_on_push = true
  }
}
