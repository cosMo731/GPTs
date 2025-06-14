resource "aws_ecs_cluster" "this" {
  name = "${var.prefix}-cluster"
}

output "cluster_arn" {
  value = aws_ecs_cluster.this.arn
}

output "cluster_name" {
  value = aws_ecs_cluster.this.name
}
