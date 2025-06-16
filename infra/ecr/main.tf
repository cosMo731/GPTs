resource "aws_ecr_repository" "backend" {
  name = "django-backend"
}

output "backend_repository_url" {
  value = aws_ecr_repository.backend.repository_url
}
