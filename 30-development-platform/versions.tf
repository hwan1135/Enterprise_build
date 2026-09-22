terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket       = "REPLACE_WITH_STATE_BUCKET"
    key          = "30-development-platform/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4"
    }
  }
}