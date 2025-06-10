region = "us-east-1"
prefix = "prod"

vpc_cidr        = "10.20.0.0/16"
azs             = ["us-east-1a", "us-east-1b"]
public_subnets  = ["10.20.1.0/24", "10.20.2.0/24"]
private_subnets = ["10.20.101.0/24", "10.20.102.0/24"]
allowed_ips     = ["0.0.0.0/0"]

db_username = "prod_user"
db_password = "change_me_prod"

ecs_execution_role_arn = "arn:aws:iam::123456789012:role/ecsExecutionRole"
ecs_task_role_arn      = "arn:aws:iam::123456789012:role/ecsTaskRole"
app_environment = {
  ENV = "production"
}

lambda_zip_path = "../lambda/prod_handler.zip"
lambda_handler  = "index.handler"
lambda_runtime  = "python3.11"
lambda_environment = {
  STAGE = "prod"
}

sfn_definition = "../step_functions/definition.json"
sfn_role_arn   = "arn:aws:iam::123456789012:role/sfnRole"

log_group_kms_key = null
