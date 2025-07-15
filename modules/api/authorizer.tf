# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/7.20.1
module "authorizer" {
  for_each = var.authorizers

  source  = "terraform-aws-modules/lambda/aws"
  version = "7.20.1"

  architectures = ["arm64"]
  description   = "${each.key} authorizer for API gateway ${var.api_name}"
  function_name = "${var.api_name}-authorizer-${each.key}"
  handler       = "main.lambda_handler"
  runtime       = "python3.12"
  source_path   = "${path.root}/code/authorizer/${each.key}"

  environment_variables = each.value.environment

  trusted_entities = [
    "apigateway.amazonaws.com",
  ]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_authorizer
resource "aws_api_gateway_authorizer" "this" {
  for_each = var.authorizers

  authorizer_credentials = aws_iam_role.this.arn
  authorizer_uri         = module.authorizer[each.key].lambda_function_invoke_arn
  rest_api_id            = aws_api_gateway_rest_api.this.id
  name                   = each.key

  authorizer_result_ttl_in_seconds = each.value.result_ttl_in_seconds
  identity_source                  = each.value.identity_source
  type                             = each.value.type
}
