resource "aws_iam_role" "this" {
  name               = "${var.api_name}"
  assume_role_policy = file("iam/assume/api_gateway.json")
}

resource "aws_iam_policy" "this" {
  name = "${var.api_name}"

  policy = templatefile("${path.root}/iam/policies/api_gateway.json", {
    region     = local.region
    account_id = local.account_id
    api_name   = var.api_name
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_iam_role_policy_attachment" "api_gateway_stepfunctions" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
}
