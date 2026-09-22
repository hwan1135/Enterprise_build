data "aws_ssoadmin_instances" "this" {}

locals {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  instance_arn      = tolist(data.aws_ssoadmin_instances.this.arns)[0]

  groups = toset([
    "Cloud-Platform-Admins",
    "Network-Admins",
    "Security-Auditors",
    "App-Developers",
    "Production-Operators",
    "ReadOnly-Auditors"
  ])
}

resource "aws_identitystore_group" "this" {
  for_each = local.groups

  identity_store_id = local.identity_store_id
  display_name      = each.value
  description       = "Managed by Terraform"
}

resource "aws_ssoadmin_permission_set" "platform_admin" {
  name             = "PlatformAdministrator"
  description      = "Administrative access for approved cloud platform personnel."
  instance_arn     = local.instance_arn
  session_duration = "PT4H"
}

resource "aws_ssoadmin_managed_policy_attachment" "platform_admin" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.platform_admin.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_ssoadmin_permission_set" "developer" {
  name             = "DeveloperPowerUser"
  description      = "Development account access without routine IAM administration."
  instance_arn     = local.instance_arn
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "developer" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.developer.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_ssoadmin_permission_set" "readonly" {
  name             = "ReadOnly"
  description      = "Read-only operational and audit access."
  instance_arn     = local.instance_arn
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "readonly" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

locals {
  assignments = {
    platform_admin_dev = {
      group_name         = "Cloud-Platform-Admins"
      permission_set_arn = aws_ssoadmin_permission_set.platform_admin.arn
      account_id         = var.development_account_id
    }

    platform_admin_shared = {
      group_name         = "Cloud-Platform-Admins"
      permission_set_arn = aws_ssoadmin_permission_set.platform_admin.arn
      account_id         = var.shared_services_account_id
    }

    developers_dev = {
      group_name         = "App-Developers"
      permission_set_arn = aws_ssoadmin_permission_set.developer.arn
      account_id         = var.development_account_id
    }

    auditors_dev = {
      group_name         = "Security-Auditors"
      permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
      account_id         = var.development_account_id
    }

    auditors_prod = {
      group_name         = "Security-Auditors"
      permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
      account_id         = var.production_account_id
    }
  }
}

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = local.assignments

  instance_arn       = local.instance_arn
  permission_set_arn = each.value.permission_set_arn
  principal_id       = aws_identitystore_group.this[each.value.group_name].group_id
  principal_type     = "GROUP"
  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"
}