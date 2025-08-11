locals {
  # Globals
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  # create_stage = true
  name           = "agc-auth"
  fmt_name       = "${local.name}-%s"
  lambda_uri_fmt = "arn:aws:apigateway:${local.region}:lambda:path/2015-03-31/functions/%s/invocations"

  # API output
  resource_id          = module.api.setup.resource_id
  rest_api_domain_name = module.api.setup.rest_api_domain_name
  rest_api_id          = module.api.setup.rest_api_id

  authorizer = {
    lambda_arn            = module.ping.lambda_function_invoke_arn
    identity_source       = "method.request.header.authToken"
    result_ttl_in_seconds = 300
    type                  = "TOKEN"
  }

  api = {
    "document_read" = {
      authorized  = false
      http_method = "GET"
      resource    = "documents"
    }

    "document_create" = {
      authorized  = true
      http_method = "POST"
      resource    = "documents"
    }
  }
}
