resource "aws_cloudfront_distribution" "s3_distribution" {

  origin {
    domain_name = aws_s3_bucket.web-bucket.bucket_regional_domain_name
    origin_id   = var.s3_origin_id

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${var.oai}"
    }
  }
  

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "TF cloudfront"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD",]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 1
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    
    # This is how we associate the Lambda@Edge function for a cache behavior
    lambda_function_association {
        event_type = "origin-response"
        lambda_arn = aws_lambda_function.lambda.qualified_arn
    }
    
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases = var.cname_aliases
  
  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  tags = var.required_tags

  depends_on = [
    aws_lambda_function.lambda,
    aws_s3_bucket_policy.web-bucket
  ]
  
}