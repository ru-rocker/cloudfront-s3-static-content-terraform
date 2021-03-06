resource "aws_sns_topic" "static_content_sns" {

  name       = "${aws_cloudfront_distribution.s3_distribution.id}-SNS"
  provider   = aws.lambda-edge
  tags       = var.required_tags

  depends_on = [
    aws_cloudfront_distribution.s3_distribution,
  ]

}

resource "aws_sns_topic_subscription" "static_content_sns_subscription" {
  topic_arn = aws_sns_topic.static_content_sns.arn
  provider  = aws.lambda-edge
  protocol  = "email"
  endpoint  = var.email_subscriber
}
