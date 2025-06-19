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
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  web_acl_id = var.web_acl_id
  tags       = var.tags
}

variable "s3_domain_name" {
  type        = string
  description = "Domain name of the S3 origin"
}

variable "web_acl_id" {
  type        = string
  description = "ID of the WAF Web ACL"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
