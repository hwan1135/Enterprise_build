provider "aws" {
  alias   = "shared"
  region  = var.region
  profile = var.aws_profile

  assume_role {
    role_arn = "arn:aws:iam::${var.shared_services_account_id}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias   = "dev"
  region  = var.region
  profile = var.aws_profile

  assume_role {
    role_arn = "arn:aws:iam::${var.development_account_id}:role/OrganizationAccountAccessRole"
  }

  default_tags {
    tags = local.required_tags
  }
}