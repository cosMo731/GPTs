resource "aws_lb" "main" {
  name               = var.name
  load_balancer_type = "application"
  subnets            = var.subnet_ids
}

variable "name" { type = string }
variable "subnet_ids" { type = list(string) }
