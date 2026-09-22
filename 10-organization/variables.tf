variable "region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = "platform-admin"
}

variable "organization_name" {
  type    = string
  default = "example"
}

variable "account_emails" {
  description = "Unique email addresses for AWS member accounts."
  type = object({
    log_archive     = string
    security        = string
    shared_services = string
    development     = string
    production      = string
  })
}