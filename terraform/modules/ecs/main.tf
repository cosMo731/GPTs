resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}

variable "cluster_name" {
  type        = string
  description = "Name of the ECS cluster"
}
