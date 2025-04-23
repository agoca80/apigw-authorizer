terraform {
  backend "s3" {
    bucket       = "cpa-devops-dev-terraform-state"
    key          = "agc/experiment/api-gateway.tfstate"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.96.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
  }

  required_version = "1.11.4"
}

