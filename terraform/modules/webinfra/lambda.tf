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
