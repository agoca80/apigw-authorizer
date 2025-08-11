data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  # Globals
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  # create_stage = true
  name           = "agc-ping"
  fmt_name       = "${local.name}-%s"
  lambda_uri_fmt = "arn:aws:apigateway:${local.region}:lambda:path/2015-03-31/functions/%s/invocations"

  # DVH environments ALBs
  albs = {
    dev = "internal-dv-common-service-dev-alb-1179665779.us-east-1.elb.amazonaws.com"
  }

  # API output
  resource_id          = module.api.setup.resource_id
  rest_api_domain_name = module.api.setup.rest_api_domain_name
  rest_api_id          = module.api.setup.rest_api_id
}

resource "aws_cloudwatch_log_group" "this" {
  name = format(local.fmt_name, "logs")
}

# https://registry.terraform.io/modules/terraform-aws-modules/dynamodb-table/aws/latest
module "dynamodb" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "4.3.0"

  name     = format(local.fmt_name, "dynamodb")
  hash_key = "uuid"

  attributes = [
    {
      name = "uuid"
      type = "S"
    }
  ]
}

# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/7.20.1
module "authorizer" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.20.1"

  architectures = ["arm64"]
  description   = "JWT authorizer for API gateway ${local.name}"
  function_name = "${local.name}-authorizer"
  handler       = "main.lambda_handler"
  runtime       = "python3.12"
  source_path   = "${path.root}/code/authorizer"

  # Allow API Gateway to call the lambda
  # See Q4 for "We currently do not support adding policies for $LATEST" error message
  # https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest#faq
  create_current_version_allowed_triggers = true
  publish                                 = true

  allowed_triggers = {
    "authorizer" = {
      service      = "apigateway"
      statement_id = "apigw-authorizer-"
      source_arn   = "arn:aws:execute-api:${local.region}:${local.account_id}:${local.rest_api_id}/*/*/*"
    }
  }

  environment_variables = {
    AUDIENCE  = var.audience
    TENANT_ID = var.tenant_id
  }

  trusted_entities = [
    "apigateway.amazonaws.com",
  ]
}

# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/7.20.1
module "ping" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.20.1"

  architectures = ["arm64"]
  description   = "JWT authorizer for API gateway ${local.name}"
  function_name = "${local.name}-ping"
  handler       = "main.lambda_handler"
  runtime       = "python3.12"
  source_path   = "${path.root}/code/ping"

  # Allow API Gateway to call the lambda
  # See Q4 for "We currently do not support adding policies for $LATEST" error message
  # https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest#faq
  create_current_version_allowed_triggers = true
  publish                                 = true

  allowed_triggers = {
    "authorizer" = {
      service      = "apigateway"
      statement_id = "apigw-authorizer-"
      source_arn   = "arn:aws:execute-api:${local.region}:${local.account_id}:${local.rest_api_id}/*/*/*"
    }
  }

  environment_variables = {
    PING_URL           = var.ping_url
    PING_CLIENT_ID     = var.ping_client_id
    PING_CLIENT_SECRET = var.ping_client_secret
  }

  trusted_entities = [
    "apigateway.amazonaws.com",
  ]
}


module "api" {
  source = "./modules/api"

  authorizer     = local.authorizer
  api            = local.api
  api_name       = local.name
  hosted_zone_id = var.hosted_zone_id
}

module "method" {
  for_each = local.api

  source = "./modules/methods"

  resource_id = local.resource_id[each.value.resource]
  rest_api_id = local.rest_api_id
  uri         = format("arn:aws:apigateway:${local.region}:lambda:path/2015-03-31/functions/%s/invocations", module.lambda[each.key].lambda_function_arn)

  authorizer_id = each.value.authorized ? module.api.authorizer_id : null
  http_method   = each.value.http_method
}

module "stage" {
  source = "./modules/stages"

  api_name             = local.name
  base_path            = null
  rest_api_id          = local.rest_api_id
  rest_api_domain_name = local.rest_api_domain_name
  stage_name           = "default"

  variables = {
    "path"  = "/"
    "stage" = "default"
    "flag"  = "foo"

    "StageVar1" = "stageValue1"
  }
}
