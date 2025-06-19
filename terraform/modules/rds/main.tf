resource "aws_db_instance" "main" {
  identifier          = var.identifier
  engine              = "postgres"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  username            = var.username
  password            = var.password
  skip_final_snapshot = true
  performance_insights_enabled = true
  tags                        = var.tags
}

variable "identifier" {
  type        = string
  description = "Identifier of the RDS instance"
}

variable "username" {
  type        = string
  description = "Master username"
}

variable "password" {
  type        = string
  description = "Master password"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}