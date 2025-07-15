variable "audience" {
  default = "api://9ca5f6b2-4ad1-438c-87fe-06432bc1c538"
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

variable "name" {
  default     = "agc-c0f4"
  description = "The prefix for the name of all AWS resources."
  type        = string
}

variable "stages" {
  default = {
    dev = {
      base_path        = "dev"
      allow_by_default = true

      variables = {
        "path"  = "/dev"
        "stage" = "dev"
        "flag"  = "foo"

        "StageVar1" = "stageValue1"
      }
    }


    prod = {
      base_path        = null
      allow_by_default = false
      disabled         = true

      variables = {
        "path"  = "/"
        "stage" = "prod"
        "flag"  = "bar"

        "StageVar1" = "stageValue1"
      }
    }
  }

  type = map(object({
    base_path        = optional(string)
    allow_by_default = optional(bool)
    disabled         = optional(bool)
    variables        = map(string)
  }))
}

variable "log_retention_in_days" {
  description = "The number of days to retain logs in CloudWatch."
  type        = number
  default     = 1
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
