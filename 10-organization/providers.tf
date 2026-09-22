provider "aws" {
  region  = var.region
  profile = var.aws_profile

  default_tags {
    tags = {
      Application = "enterprise-platform"
      Environment = "shared"
      ManagedBy   = "terraform"
      Owner       = "cloud-platform"
    }
  }
}