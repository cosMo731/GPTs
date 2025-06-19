resource "aws_lambda_function" "main" {
  function_name = var.function_name
  handler       = var.handler
  runtime       = "python3.12"
  role          = var.role_arn
  filename      = var.filename
  tags          = var.tags
  tracing_config {
    mode = "Active"
  }
}

variable "function_name" {
  type        = string
  description = "Name of the Lambda function"
}

variable "handler" {
  type        = string
  description = "Handler entry point"
}

variable "role_arn" {
  type        = string
  description = "IAM role ARN"
}

variable "filename" {
  type        = string
  description = "Deployment package"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}