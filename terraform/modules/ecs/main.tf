resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
  tags = var.tags
}

variable "cluster_name" {
  type        = string
  description = "Name of the ECS cluster"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}