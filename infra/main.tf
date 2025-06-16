terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

module "ecs" {
  source        = "./ecs"
  backend_image = var.backend_image
}

module "ecr" {
  source = "./ecr"
}

module "storage" {
  source           = "./s3_cloudfront"
  frontend_bucket  = var.frontend_bucket
}
