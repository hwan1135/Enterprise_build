variable "region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = "platform-admin"
}

variable "development_account_id" {
  type = string
}

variable "shared_services_account_id" {
  type = string
}

variable "organization_name" {
  type    = string
  default = "example"
}

variable "application_name" {
  type    = string
  default = "reference-app"
}

variable "public_zone_name" {
  description = "Existing or delegated public DNS zone."
  type        = string
  default     = "example.com"
}

variable "container_image" {
  description = "Approved image URI, preferably from the development ECR repository."
  type        = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}