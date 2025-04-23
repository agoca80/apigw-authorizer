data "aws_api_gateway_rest_api" "this" {
  name = var.api_name
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  # Globals
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/api_gateway/${var.api_name}/${var.stage_name}"
  retention_in_days = 1
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = var.rest_api_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = var.rest_api_id
  stage_name    = var.stage_name
  variables     = try(var.variables, {})

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.this.arn
    format          = "$context.requestId $context.identity.sourceIp $context.identity.caller $context.identity.user $context.requestTime $context.httpMethod $context.resourcePath $context.status $context.protocol $context.responseLength"
  }
}

resource "aws_api_gateway_base_path_mapping" "this" {
  api_id      = var.rest_api_id
  base_path   = var.base_path
  domain_name = var.rest_api_domain_name
  stage_name  = var.stage_name
}
