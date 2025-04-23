data "aws_acm_certificate" "current" {
  domain   = data.aws_route53_zone.current.name
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "current" {
  zone_id      = var.hosted_zone_id
  private_zone = true
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  # Globals
  account_id  = data.aws_caller_identity.current.account_id
  domain_name = data.aws_route53_zone.current.name
  region      = data.aws_region.current.name

  # Internal
  resources = distinct([for name, method in var.api : method.resource])
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api
resource "aws_api_gateway_rest_api" "this" {
  name = var.api_name

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# https://registry.terraform.io/providers/-/aws/latest/docs/resources/api_gateway_rest_api_policy
resource "aws_api_gateway_rest_api_policy" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  policy = templatefile("iam/policies/api_policy.json", {
    region     = local.region
    account_id = local.account_id
    api_id     = aws_api_gateway_rest_api.this.id
  })
}

resource "aws_api_gateway_resource" "this" {
  for_each = toset(local.resources)

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.key
}

resource "aws_route53_record" "this" {
  name    = aws_api_gateway_domain_name.this.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.current.id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.this.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.this.regional_zone_id
  }
}

resource "aws_api_gateway_domain_name" "this" {
  domain_name              = format("%s.%s", var.api_name, local.domain_name)
  regional_certificate_arn = data.aws_acm_certificate.current.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

output "setup" {
  value = {
    authorizer_id        = { for name, authorizer in aws_api_gateway_authorizer.this : name => authorizer.id }
    resource_id          = { for name, resource in aws_api_gateway_resource.this : name => resource.id }
    rest_api_domain_name = aws_api_gateway_domain_name.this.domain_name
    rest_api_id          = aws_api_gateway_rest_api.this.id
  }
}
