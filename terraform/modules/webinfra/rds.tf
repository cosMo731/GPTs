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
