# https://registry.terraform.io/modules/terraform-aws-modules/dynamodb-table/aws/latest
module "dynamodb" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "4.3.0"

  name     = format(local.name_fmt, "dynamodb")
  hash_key = "uuid"

  attributes = [
    {
      name = "uuid"
      type = "S"
    }
  ]
}
