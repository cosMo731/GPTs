resource "aws_ecr_repository" "main" {
  name                 = var.name
  image_tag_mutability = "IMMUTABLE"
}

output "repository_url" {
  value = aws_ecr_repository.main.repository_url
}

variable "name" {
  type = string
}
