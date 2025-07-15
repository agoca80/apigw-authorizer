data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  # Globals
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  # create_stage = true
  name_fmt       = "${var.name}-%s"
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

# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/7.20.1
module "authorizer" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.20.1"

  architectures = ["arm64"]
  description   = "JWT authorizer for API gateway ${var.name}"
  function_name = "${var.name}-authorizer"
  handler       = "main.lambda_handler"
  runtime       = "python3.12"
  source_path   = "${path.root}/code/authorizer"

  environment_variables = {
    AUDIENCE  = var.audience
    TENANT_ID = var.tenant_id
  }

  trusted_entities = [
    "apigateway.amazonaws.com",
  ]
}

module "api" {
  source = "./modules/api"

  authorizer     = local.authorizer
  api            = local.api
  api_name       = var.name
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

module "stages" {
  for_each = var.stages

  source = "./modules/stages"

  api_name             = var.name
  base_path            = each.value.base_path
  rest_api_id          = local.rest_api_id
  rest_api_domain_name = local.rest_api_domain_name
  stage_name           = each.key
  variables            = each.value.variables
}

output "setup" {
  value = module.api.setup
}

output "authorizer_id" {
  value = module.api.authorizer_id
}
