data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "lambda"
  output_path = "lambda/lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  filename         = "lambda/lambda.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.iam_for_lambda.arn
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler          = var.lambda_handler_name
  runtime          = var.lambda_runtime
  provider         = aws.lambda-edge
  publish          = "true"
  tags             = var.required_tags

  depends_on = [
    aws_cloudwatch_log_group.log_group
  ]
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 3
  tags = var.required_tags
}
