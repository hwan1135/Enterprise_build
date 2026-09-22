##############################################################
# Data Sources
##############################################################

# Use SSM parameter to look up latest RHEL 9 AMI if no AMI ID is provided
data "aws_ssm_parameter" "rhel9_ami" {
  name = "/aws/service/redhat/release/amazon-linux-gp3/9.0/x86_64/latest"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Use default VPC if none is specified
data "aws_vpc" "default" {
  count   = var.vpc_id == "" ? 1 : 0
  default = true
}

data "aws_subnets" "default" {
  count  = var.subnet_id == "" ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [var.vpc_id == "" ? data.aws_vpc.default[0].id : var.vpc_id]
  }
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

locals {
  ami_id     = var.ami_id != "" ? var.ami_id : data.aws_ssm_parameter.rhel9_ami.value
  vpc_id     = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.default[0].id
  subnet_id  = var.subnet_id != "" ? var.subnet_id : data.aws_subnets.default[0].ids[0]
}

##############################################################
# EC2 Instance — Hardened Configuration
##############################################################

resource "aws_instance" "stig_hardened" {
  ami                    = local.ami_id
  instance_type          = var.instance_type
  subnet_id              = local.subnet_id
  key_name               = var.key_name != "" ? var.key_name : null
  vpc_security_group_ids = [aws_security_group.stig_instance.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm.name

  # Enforce IMDSv2 (DISA STIG requirement)
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
    http_put_response_hop_limit = 1
  }

  # Encrypted root EBS volume (DISA STIG requirement)
  root_block_device {
    encrypted   = true
    kms_key_id  = aws_kms_key.ebs_encryption.arn
    volume_size = var.root_volume_size
    volume_type = "gp3"
    iops        = 3000
    throughput  = 125

    tags = {
      Name = "${var.instance_name}-root-volume"
    }
  }

  # Cloud-init: install and run OpenSCAP STIG remediation on boot
  user_data = templatefile("${path.module}/user_data_stig.sh.tftpl", {
    stig_profile = "stig"
  })

  monitoring             = var.enable_detailed_monitoring
  associate_public_ip_address = false

  tags = {
    Name        = var.instance_name
    STIGHardened = "true"
  }

  lifecycle {
    # Prevent accidental destruction of production instances
    prevent_destroy = var.environment == "prod" ? true : false

    # Recreate if security-critical settings change
    create_before_destroy = false
  }
}

##############################################################
# KMS Key for EBS Encryption
##############################################################

resource "aws_kms_key" "ebs_encryption" {
  description             = "KMS key for EBS volume encryption (DISA STIG)"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableIAMPermissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowEC2ServiceToUseKey"
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "ebs-encryption-key"
  }
}

resource "aws_kms_alias" "ebs_encryption" {
  name          = "alias/ebs-stig-encryption"
  target_key_id = aws_kms_key.ebs_encryption.key_id
}
