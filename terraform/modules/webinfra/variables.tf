# General settings
variable "region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "prefix" {
  description = "Prefix used for all resources"
  type        = string
}

# CIDR blocks for VPC and subnets
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDRs for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDRs for private subnets"
  type        = list(string)
}

# IP ranges allowed to access ALB
variable "allowed_ips" {
  description = "List of CIDR blocks allowed through the ALB"
  type        = list(string)
}

# RDS credentials
variable "db_username" {
  description = "Database master username"
  type        = string
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

# ECS roles (pre-existing IAM roles)
variable "ecs_execution_role_arn" {
  description = "ARN of existing ECS execution role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN of existing ECS task role"
  type        = string
}

# Environment variables for the ECS container
variable "app_environment" {
  description = "Key/value pairs for application container"
  type        = map(string)
}

# Lambda settings
variable "lambda_zip_path" {
  description = "Path to local zip file for Lambda code"
  type        = string
}

variable "lambda_handler" {
  description = "Lambda handler name"
  type        = string
}

variable "lambda_runtime" {
  description = "Runtime for Lambda"
  type        = string
}

variable "lambda_environment" {
  description = "Environment variables for Lambda"
  type        = map(string)
}

variable "log_group_kms_key" {
  description = "KMS key ARN for CloudWatch log group encryption"
  type        = string
  default     = null
}

# Step function definition file and role
variable "sfn_definition" {
  description = "Path to state machine JSON definition"
  type        = string
}

variable "sfn_role_arn" {
  description = "ARN of IAM role for Step Functions"
  type        = string
}

