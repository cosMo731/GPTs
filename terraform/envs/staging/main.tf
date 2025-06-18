terraform {
  required_version = "~> 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

module "s3" {
  source = "../../modules/s3"
  bucket = var.s3_bucket_name
}

module "ecr" {
  source = "../../modules/ecr"
  name   = var.ecr_repository_name
}

module "ecs" {
  source       = "../../modules/ecs"
  cluster_name = var.ecs_cluster_name
}

module "rds" {
  source     = "../../modules/rds"
  identifier = var.rds_identifier
  username   = var.rds_username
  password   = var.rds_password
}

module "lambda" {
  source        = "../../modules/lambda"
  function_name = var.lambda_function_name
  handler       = var.lambda_handler
  role_arn      = var.lambda_role_arn
  filename      = var.lambda_filename
}

module "alb" {
  source     = "../../modules/alb"
  name       = var.alb_name
  subnet_ids = var.alb_subnet_ids
  internal   = var.alb_internal
}

module "cloudfront" {
  source         = "../../modules/cloudfront"
  s3_domain_name = module.s3.bucket_domain_name
  web_acl_id     = var.cloudfront_web_acl_id
}
