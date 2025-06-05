variable "bucket_name" {
  type = string
}

variable "source_code_archive" {
  type = string
  description = "Path to zipped source code from GitLab"
}

resource "aws_s3_bucket" "code" {
  bucket = var.bucket_name
  acl    = "private"
}

resource "aws_s3_bucket_object" "code" {
  bucket = aws_s3_bucket.code.id
  key    = basename(var.source_code_archive)
  source = var.source_code_archive
}

output "bucket_id" {
  value = aws_s3_bucket.code.id
}

output "object_key" {
  value = aws_s3_bucket_object.code.key
}
