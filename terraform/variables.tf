##############################################################
# Input Variables
##############################################################

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "owner" {
  description = "Owner email or team name for resource tagging"
  type        = string
  default     = "security-team@example.com"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "stig-hardened-instance"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID for RHEL 9. Leave empty to use latest from SSM parameter"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "SSH key pair name for EC2 access"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID where the instance will be deployed"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to access SSH (use SSM instead when possible)"
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = var.allowed_ssh_cidr != "0.0.0.0/0" || var.environment == "dev"
    error_message = "Restrict SSH CIDR in non-dev environments. Use SSM Session Manager instead."
  }
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 50
}

variable "enable_detailed_monitoring" {
  description = "Enable CloudWatch detailed monitoring"
  type        = bool
  default     = true
}
