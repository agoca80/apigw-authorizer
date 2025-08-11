variable "audience" {
  default = "api://97a9f0a2-9ef0-4088-9b76-f7144813e6e3"
  type    = string
}

variable "tenant_id" {
  default = "b2c9c85a-71f3-48a1-8311-e106f47ff3f8"
  type    = string
}

variable "hosted_zone_id" {
  default     = "Z0851669L1AZ85HCW6V5" # dev.cpa-devops.aws.clarivate.net 
  description = "The hosted zone id for the application."
  type        = string
}

variable "log_retention_in_days" {
  description = "The number of days to retain logs in CloudWatch."
  type        = number
  default     = 1
}

variable "ping_url" {
  description = "The URL for the Ping Federate server."
  type        = string
}

variable "ping_client_id" {
}

variable "ping_client_secret" {
}

variable "tags" {
  description = "A map of tags to assign to all resources."
  type        = map(string)
  default = {
    Product     = "agc-test"
    Component   = "poc"
    Environment = "poc"
    Layer       = "poc"
    Owner       = "antxon.gonzalez@clarivate.com"
    Experiment  = "api-gateway"
  }
}
