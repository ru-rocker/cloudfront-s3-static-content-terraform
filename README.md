# Overview
Infrastructure as a Code for static content deployment using CloudFront, S3 and lambda@edge.

Since the project is based on angular, so we need to use lambda@edge for client side routing.
Because if we hit refresh button, CloudFront always look for the file or folder.
Meanwhile for angular, we just want to do client side routing.
*See the logic for lambda@edge under lambda/response_header_lambda.js*

# Project Structure
All files is divided based on AWS resources, except for Dashboard and Metrics.

# Steps
Steps to execute:

     terraform init # initialized terraform project
     terraform plan -var-file="dev/terraform.tfvars"
     terraform apply -var-file="dev/terraform.tfvars"
     terraform destroy -var-file="dev/terraform.tfvars"

_Note: variables are split based on environment._

# Debugging
Sometimes, you need to debug your executions. Please export *TF_LOG* into your environment variables.
The values are: *TRACE*, *DEBUG*, *INFO*, *WARN*, *ERROR*

     # example enable DEBUG
     export TF_LOG=DEBUG

# Reference
* https://andrewlock.net/using-lambda-at-edge-to-handle-angular-client-side-routing-with-s3-and-cloudfront/
