variable "aws_region" { type = string }
variable "s3_bucket_name" { type = string }
variable "ecr_repository_name" { type = string }
variable "ecs_cluster_name" { type = string }
variable "rds_identifier" { type = string }
variable "rds_username" { type = string }
variable "rds_password" { type = string }
variable "lambda_function_name" { type = string }
variable "lambda_handler" { type = string }
variable "lambda_role_arn" { type = string }
variable "lambda_filename" { type = string }
variable "alb_name" { type = string }
variable "alb_subnet_ids" { type = list(string) }
variable "alb_internal" {
  type        = bool
  description = "Whether the ALB is internal"
  default     = true
}
variable "cloudfront_web_acl_id" {
  type        = string
  description = "ID of the WAF Web ACL for CloudFront"
  default     = ""
}
