resource "aws_api_gateway_method" "this" {
  authorization = var.authorizer_id == null ? "NONE" : "CUSTOM"
  authorizer_id = var.authorizer_id
  http_method   = var.http_method
  resource_id   = var.resource_id
  rest_api_id   = var.rest_api_id
}

# Do not use for AWS_PROXY integrations with lambda triggers
# credentials             = each.value.credentials
#
# https://registry.terraform.io/providers/hashicorp/aws/5.95.0/docs/resources/api_gateway_integration
resource "aws_api_gateway_integration" "this" {
  integration_http_method = "POST"
  http_method             = var.http_method
  rest_api_id             = var.rest_api_id
  resource_id             = var.resource_id
  type                    = "AWS_PROXY"
  uri                     = var.uri
}

resource "aws_api_gateway_method_response" "this" {
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = var.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "this" {
  http_method = var.http_method
  resource_id = var.resource_id
  rest_api_id = var.rest_api_id
  status_code = "201"
}
