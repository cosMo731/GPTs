resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name = var.s3_domain_name
    origin_id   = "s3-origin"
  }

  enabled = true
  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = "s3-origin"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

variable "s3_domain_name" {
  type        = string
  description = "Domain name of the S3 origin"
}
