variable "api" {
  default = {
    "document_read" = {
      lambda      = "read"
      http_method = "GET"
      resource    = "documents"
    }

    "document_create" = {
      authorizer  = "token"
      lambda      = "create"
      http_method = "POST"
      resource    = "documents"
    }

    # "document_delete" = {
    #   lambda      = "delete"
    #   http_method = "DELETE"
    #   resource    = "documents"
    # }


    # "document_update" = {
    #   lambda      = "update"
    #   http_method = "PUT"
    #   resource    = "documents"
    # }
  }
  description = "The API Gateway configuration."

  type = map(object({
    authorizer  = optional(string, "")
    lambda      = string
    http_method = string
    resource    = string
  }))
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

variable "authorizers" {
  default = {

    token = {
      identity_source       = "method.request.header.authToken"
      result_ttl_in_seconds = 300
      type                  = "TOKEN"
    }

    request = {
      identity_source       = "method.request.header.HeaderAuth1,method.request.querystring.QueryString1,stageVariables.StageVar1"
      result_ttl_in_seconds = 0
      type                  = "REQUEST"
    }

    # Cognito authorizers require a list of provider ARNs
    # cognito = {
    #   type = "COGNITO_USER_POOLS"
    # }
  }

  type = map(object({
    result_ttl_in_seconds = number
    identity_source       = optional(string)
    type                  = string
  }))
}

