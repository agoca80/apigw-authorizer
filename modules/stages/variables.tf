variable "api_name" {}
variable "base_path" {}
variable "rest_api_id" {}
variable "rest_api_domain_name" {}
variable "stage_name" {}

variable "variables" {
  default = {}
  type    = map(string)
}
