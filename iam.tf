resource "aws_iam_policy" "lambda" {
  description = "${local.name} IAM policy for lambda"
  name        = format(local.fmt_name, "lambda")

  policy = templatefile("iam/policies/lambda.json", {
    table = module.dynamodb.dynamodb_table_arn
  })
}
