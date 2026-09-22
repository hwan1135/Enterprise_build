locals {
  accounts = {
    log_archive = {
      name  = "${var.organization_name}-log-archive"
      email = var.account_emails.log_archive
      ou    = "Security"
    }

    security = {
      name  = "${var.organization_name}-security"
      email = var.account_emails.security
      ou    = "Security"
    }

    shared_services = {
      name  = "${var.organization_name}-shared-services"
      email = var.account_emails.shared_services
      ou    = "Infrastructure"
    }

    development = {
      name  = "${var.organization_name}-development"
      email = var.account_emails.development
      ou    = "Workloads-NonProd"
    }

    production = {
      name  = "${var.organization_name}-production"
      email = var.account_emails.production
      ou    = "Workloads-Prod"
    }
  }
}

resource "aws_organizations_organization" "this" {
  feature_set = "ALL"

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY"
  ]
}

resource "aws_organizations_organizational_unit" "this" {
  for_each = toset([
    "Security",
    "Infrastructure",
    "Workloads-NonProd",
    "Workloads-Prod"
  ])

  name      = each.value
  parent_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_account" "this" {
  for_each = local.accounts

  name      = each.value.name
  email     = each.value.email
  parent_id = aws_organizations_organizational_unit.this[each.value.ou].id

  role_name = "OrganizationAccountAccessRole"

  tags = {
    Application = "enterprise-platform"
    Environment = each.key == "production" ? "prod" : "shared"
    ManagedBy   = "terraform"
    Owner       = "cloud-platform"
  }

  lifecycle {
    ignore_changes = [role_name]
  }
}