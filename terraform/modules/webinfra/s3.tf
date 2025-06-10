# S3 bucket for website hosting.
module "s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.1"

  bucket = "${var.prefix}-site"
  acl    = "public-read"

  website = {
    index_document = "index.html"
  }
}
