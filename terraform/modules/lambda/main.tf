resource "aws_lambda_function" "main" {
  function_name = var.function_name
  handler       = var.handler
  runtime       = "python3.12"
  role          = var.role_arn
  filename      = var.filename
}

variable "function_name" { type = string }
variable "handler" { type = string }
variable "role_arn" { type = string }
variable "filename" { type = string }
