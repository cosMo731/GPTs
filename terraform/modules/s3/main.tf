resource "aws_s3_bucket" "main" {
  bucket = var.bucket
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

output "bucket_domain_name" {
  value = aws_s3_bucket.main.bucket_domain_name
}

variable "bucket" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
