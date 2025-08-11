# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/7.20.1
module "lambda" {
  for_each = local.api

  source  = "terraform-aws-modules/lambda/aws"
  version = "7.20.1"

  architectures = ["arm64"]
  attach_policy = true
  description   = format("%s lambda for %s", each.key, local.name)
  function_name = format(local.fmt_name, each.key)
  handler       = "main.lambda_handler"
  policy        = aws_iam_policy.lambda.arn
  runtime       = "python3.12"
  source_path   = "${path.root}/code/${each.key}"

  environment_variables = {
    DYNAMODB_TABLE = module.dynamodb.dynamodb_table_id
  }

  # Allow API Gateway to call the lambda
  # See Q4 for "We currently do not support adding policies for $LATEST" error message
  # https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest#faq
  create_current_version_allowed_triggers = true
  publish                                 = true

  # source_arn example: arn:aws:execute-api:REGION:ACCOUNT_ID:API_ID/*/GET/RESOURCE"
  # Do not use credentials on aws_api_gateway_integration while using triggers with AWS_PROXY integrations!!!
  allowed_triggers = {
    for name, method in local.api : "${name}" => {
      service      = "apigateway"
      statement_id = "${name}-"
      source_arn   = "arn:aws:execute-api:${local.region}:${local.account_id}:${local.rest_api_id}/*/${method.http_method}/${method.resource}"
    }
  }
}
