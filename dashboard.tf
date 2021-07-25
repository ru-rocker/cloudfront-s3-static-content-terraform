data "template_file" "cloudfront_metrics_json" {
  template = "${file("${path.module}/template/cloudfront-metrics.json.tmpl")}"
  vars = {
    distribution_id = aws_cloudfront_distribution.s3_distribution.id
  }
}

data "template_file" "lambda_metrics_json" {
  template = "${file("${path.module}/template/lambda-at-edge-metrics.json.tmpl")}"
  vars = {
    lambda_name = var.lambda_function_name
  }
}

data "template_file" "widgets" {
  template = <<EOF
    {
      "widgets": [
        {
        "type": "metric",
        "width": 24,
        "height": 6,
        "x": 0,
        "y": 0,
        "properties": {
            "view": "singleValue",
            "title": "CloudFront Status",
            "region": "us-east-1",
            "stat": "Average",
            "stacked": false,
            "period": 300,
            "metrics": [
                ${join(", \n               ", data.template_file.cloudfront_metrics_json.*.rendered)}
            ]
          }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 3,
            "width": 24,
            "height": 3,
            "properties": {
                "metrics": [
                    ${join(", \n               ", data.template_file.lambda_metrics_json.*.rendered)}
                ],
                "view": "singleValue",
                "stacked": false,
                "region": "us-east-1",
                "stat": "Average",
                "period": 300,
                "title": "Lambda@Edge execution"
            }
        }
      ]
    }
  EOF
}

resource "aws_cloudwatch_dashboard" "dashboard" {
  dashboard_name = var.dashboard_name
  dashboard_body = data.template_file.widgets.rendered
}

output "widget" {
  value = data.template_file.widgets.rendered
}
