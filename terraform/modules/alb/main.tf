resource "aws_lb" "main" {
  name               = var.name
  load_balancer_type = "application"
  subnets            = var.subnet_ids
}

variable "name" {
  type        = string
  description = "Name of the ALB"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for the ALB"
}
