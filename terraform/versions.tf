terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment to use remote state (recommended for production)
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "devsecops-stig/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt         = true
  #   dynamodb_table = "terraform-locks"
  # }
}
