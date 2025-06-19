resource "aws_lb" "main" {
  name               = var.name
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  internal           = var.internal
  tags               = var.tags
  drop_invalid_header_fields = true
}

variable "name" {
  type        = string
  description = "Name of the ALB"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for the ALB"
}

variable "internal" {
  type        = bool
  description = "Whether the ALB is internal"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
