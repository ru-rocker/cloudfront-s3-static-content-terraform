resource "aws_iam_role" "iam_for_lambda" {
  name = "lambda-edge-execution-role-tf"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"]
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })

  inline_policy {
    name = "lambda_edge_policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:logs:*:*:*"
        },
      ]
    })
  }
}