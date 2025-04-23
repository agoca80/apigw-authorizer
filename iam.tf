# API Gateway IAM resources

# resource "aws_iam_role" "api_gateway" {
#   name               = format(local.name_fmt, "gateway")
#   assume_role_policy = file("iam/assume/api_gateway.json")
# }

# resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch" {
#   role       = aws_iam_role.api_gateway.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
# }


# resource "aws_iam_role_policy_attachment" "api_gateway_stepfunctions" {
#   role       = aws_iam_role.api_gateway.name
#   policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
# }

