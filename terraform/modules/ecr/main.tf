resource "aws_ecr_repository" "main" {
  name                 = var.name
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = var.tags
}

output "repository_url" {
  value = aws_ecr_repository.main.repository_url
}

variable "name" {
  type        = string
  description = "Name of the ECR repository"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}