variable "region" {
  description = "AWS Region"
}

variable "s3_origin_id" {
  description = "S3 Origin ID"
  default = "s3_origin_id"
}

variable "oai" {
  description = "Origin Access Identity"
}

variable "acm_certificate_arn" {
  description = "ACM certificate arn"
  default = ""
}

variable "cname_aliases" {
  description = "CNAME aliasees"
  type = list(string)
}

variable "lambda_function_name" {
  description = "Lambda function name"
  default = "lambda-at-edge-use-for-angular-tf"
}

variable "lambda_handler_name" {
  description = "Lambda handler"
  default = "response_header_lambda.handler"
}

variable "lambda_runtime" {
  description = "Lambda Runtime"
  default = "nodejs14.x"
}

variable "dashboard_name" {
  description = "required tags"
  default = "Cloudfront S3 Static Content"
}


variable "required_tags" {
  type = map(string)
  description = "required tags"
}
