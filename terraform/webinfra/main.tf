terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Backend resources for storing Terraform state in S3 and DynamoDB.
resource "aws_s3_bucket" "tf_state" {
  bucket        = "${var.prefix}-tfstate"
  force_destroy = false
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = {
    Name = "${var.prefix}-tfstate"
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = "${var.prefix}-tf-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }
}

# VPC using official module for multi AZ setup.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name            = "${var.prefix}-vpc"
  cidr            = var.vpc_cidr
  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway   = true
  enable_dns_hostnames = true
}

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

# ECS cluster and Fargate service with ALB.
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.7"

  cluster_name = "${var.prefix}-cluster"

  fargate_capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  services = {
    app = {
      cpu                    = 256
      memory                 = 512
      desired_count          = 1
      assign_public_ip       = false
      task_exec_iam_role_arn = var.ecs_execution_role_arn
      task_iam_role_arn      = var.ecs_task_role_arn
      container_definitions = [
        {
          name  = "app"
          image = "${module.ecr.repository_url}:latest"
          port_mappings = [
            {
              container_port = 80
              protocol       = "tcp"
            }
          ]
          environment = var.app_environment
          log_configuration = {
            log_driver = "awslogs"
            options = {
              awslogs-group         = aws_cloudwatch_log_group.app.name
              awslogs-region        = var.region
              awslogs-stream-prefix = "ecs"
            }
          }
        }
      ]
      subnet_ids = module.vpc.private_subnets
      security_group_rules = {
        alb_ingress = {
          type                     = "ingress"
          from_port                = 80
          to_port                  = 80
          protocol                 = "tcp"
          source_security_group_id = module.alb.security_group_id
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
}

# Application Load Balancer for ECS service.
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.6"

  name               = "${var.prefix}-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets

  security_group_ingress_rules = {
    http_ingress = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_blocks = var.allowed_ips
    }
  }
}

# Target group and listener for ECS service.
resource "aws_lb_target_group" "app" {
  name        = "${var.prefix}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = module.alb.lb_arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# Attach ECS service to target group
resource "aws_lb_target_group_attachment" "ecs" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = module.ecs.services["app"].tasks[0].eni_id
  port             = 80
  depends_on       = [module.ecs]
}

# RDS PostgreSQL with multi AZ.
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.2"

  identifier             = "${var.prefix}-db"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = var.db_username
  password               = var.db_password
  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  multi_az               = true
  publicly_accessible    = false
  skip_final_snapshot    = true
}

# S3 bucket for website hosting.
module "s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.1"

  bucket = "${var.prefix}-site"
  acl    = "public-read"

  website = {
    index_document = "index.html"
  }
}

# CloudFront distribution in front of S3 bucket.
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = module.s3.bucket_regional_domain_name
    origin_id   = "s3origin"
  }
  enabled             = true
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3origin"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }
  restrictions {
    geo_restriction { restriction_type = "none" }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Lambda function deployed from local zip file.
module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 6.0"

  function_name         = "${var.prefix}-handler"
  handler               = var.lambda_handler
  runtime               = var.lambda_runtime
  memory_size           = 128
  timeout               = 30
  source_path           = var.lambda_zip_path
  environment_variables = var.lambda_environment
}

# Daily EventBridge rule triggering the Lambda.
resource "aws_cloudwatch_event_rule" "daily" {
  name                = "${var.prefix}-daily"
  schedule_expression = "cron(0 0 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule = aws_cloudwatch_event_rule.daily.name
  arn  = module.lambda.lambda_function_arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily.arn
}

# Step Functions state machine using external JSON definition.
resource "aws_sfn_state_machine" "this" {
  name       = "${var.prefix}-state-machine"
  role_arn   = var.sfn_role_arn
  definition = file(var.sfn_definition)
}

# CloudWatch log group for application logs.
resource "aws_cloudwatch_log_group" "app" {
  name              = "/${var.prefix}/app"
  retention_in_days = 14
  kms_key_id        = var.log_group_kms_key
}

# CloudWatch alarm for high CPU usage of ECS service.
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "${var.prefix}-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  dimensions = {
    ClusterName = module.ecs.cluster_name
    ServiceName = module.ecs.services["app"].name
  }
}


