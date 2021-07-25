resource "aws_s3_bucket" "web-bucket" {
  bucket = "my-tf-test-web-bucket"
  acl    = "private"
  tags   = var.required_tags
}

resource "aws_s3_bucket_policy" "web-bucket" {
  bucket = aws_s3_bucket.web-bucket.id
  policy =  jsonencode({
    Version = "2012-10-17"
    Id      = "PolicyForCloudFrontPrivateContent"
    Statement = [
      {
        Sid       = "1"
        Effect    = "Allow"
        Principal = {
            AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${var.oai}"
        }
        Action    = "s3:GetObject"
        Resource = "${aws_s3_bucket.web-bucket.arn}/*",
      },
    ]
  })
}