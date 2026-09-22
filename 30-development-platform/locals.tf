locals {
  name_prefix = "${var.organization_name}-${var.application_name}-dev"

  required_tags = {
    Application = var.application_name
    Environment = "dev"
    Owner       = "cloud-platform"
    CostCenter  = "REPLACE-ME"
    ManagedBy   = "terraform"
    Criticality = "medium"
    Backup      = "daily"
    DataType    = "internal"
  }
}