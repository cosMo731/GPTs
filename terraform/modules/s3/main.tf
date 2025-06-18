resource "aws_s3_bucket" "main" {
  bucket = var.bucket
}

output "bucket_domain_name" {
  value = aws_s3_bucket.main.bucket_domain_name
}

variable "bucket" {
  type        = string
  description = "Name of the S3 bucket"
}
