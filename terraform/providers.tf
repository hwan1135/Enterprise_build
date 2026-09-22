provider "aws" {
  region = var.aws_region

  # Enforce tagging for cost allocation and compliance tracking
  default_tags {
    tags = {
      Project     = "devsecops-stig"
      Environment = var.environment
      ManagedBy  = "terraform"
      Compliance  = "DISA-STIG"
      Owner       = var.owner
    }
  }
}
