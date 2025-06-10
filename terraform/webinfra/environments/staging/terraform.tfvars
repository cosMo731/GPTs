region = "us-east-1"
prefix = "staging"

vpc_cidr        = "10.10.0.0/16"
azs             = ["us-east-1a", "us-east-1b"]
public_subnets  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnets = ["10.10.101.0/24", "10.10.102.0/24"]
allowed_ips     = ["0.0.0.0/0"]

db_username = "staging_user"
db_password = "change_me"

ecs_execution_role_arn = "arn:aws:iam::123456789012:role/ecsExecutionRole"
ecs_task_role_arn      = "arn:aws:iam::123456789012:role/ecsTaskRole"
app_environment = {
  ENV = "staging"
}

lambda_zip_path = "../lambda/staging_handler.zip"
lambda_handler  = "index.handler"
lambda_runtime  = "python3.11"
lambda_environment = {
  STAGE = "staging"
}

sfn_definition = "../step_functions/definition.json"
sfn_role_arn   = "arn:aws:iam::123456789012:role/sfnRole"

log_group_kms_key = null
