resource "aws_db_instance" "main" {
  identifier          = var.identifier
  engine              = "postgres"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  username            = var.username
  password            = var.password
  skip_final_snapshot = true
}

variable "identifier" { type = string }
variable "username" { type = string }
variable "password" { type = string }
