# alarm: 4xx cloudfront
resource "aws_cloudwatch_metric_alarm" "alarm_4xxCloudFront" {
  alarm_name          = "4xx_cloudfront_${aws_cloudfront_distribution.s3_distribution.id}"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.static_content_sns.arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 2
  evaluation_periods  = 5
  threshold           = 1
  ok_actions          = [aws_sns_topic.static_content_sns.arn]
  treat_missing_data  = "notBreaching"
  metric_query {
    id = "resp4xx"
    metric {
      metric_name = "4xxErrorRate"
      namespace   = "AWS/CloudFront"
      dimensions = {
        Region = "Global"
        DistributionId = aws_cloudfront_distribution.s3_distribution.id
      }
      stat   = "Sum"
      period = 60
    }
    return_data = true
  }
  provider         = aws.lambda-edge
  tags             = var.required_tags
}

# alarm: 5xx cloudfront
resource "aws_cloudwatch_metric_alarm" "alarm_5xxCloudFront" {
  alarm_name          = "5xx_cloudfront_${aws_cloudfront_distribution.s3_distribution.id}"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.static_content_sns.arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 2
  evaluation_periods  = 5
  threshold           = 5
  ok_actions          = [aws_sns_topic.static_content_sns.arn]
  treat_missing_data  = "notBreaching"
  metric_query {
    id = "resp5xx"
    metric {
      metric_name = "5xxErrorRate"
      namespace   = "AWS/CloudFront"
      dimensions = {
        Region = "Global"
        DistributionId = aws_cloudfront_distribution.s3_distribution.id
      }
      stat   = "Sum"
      period = 60
    }
    return_data = true
  }
  provider         = aws.lambda-edge
  tags             = var.required_tags
}

# alarm: DDoS attack
resource "aws_cloudwatch_metric_alarm" "ddos_attack" {
  alarm_name          = "DDoSDetectedAlarmForProtection_${aws_cloudfront_distribution.s3_distribution.id}"
  actions_enabled     = true
  alarm_actions       = [var.sns_topic_ddos != "" ? var.sns_topic_ddos : aws_sns_topic.static_content_sns.arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 20
  threshold           = 1
  treat_missing_data  = "notBreaching"
  metric_query {
    id = "ddos"
    metric {
      metric_name = "DDoSDetected"
      namespace   = "AWS/DDoSProtection"
      dimensions = {
        ResourceArn = "arn:aws:cloudfront::599960384020:distribution/${aws_cloudfront_distribution.s3_distribution.id}"
      }
      stat   = "Sum"
      period = 60
    }
    return_data = true
  }
  provider         = aws.lambda-edge
  tags             = var.required_tags
}
