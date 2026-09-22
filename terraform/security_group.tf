##############################################################
# Security Group — Least Privilege
##############################################################

resource "aws_security_group" "stig_instance" {
  name        = "${var.instance_name}-sg"
  description = "Security group for DISA STIG hardened instance"
  vpc_id      = local.vpc_id

  # SSH — restricted CIDR (use SSM Session Manager in production)
  dynamic "ingress" {
    for_each = var.key_name != "" ? [1] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.allowed_ssh_cidr]
      description = "SSH access (restrict in production, prefer SSM)"
    }
  }

  # All egress — restrict in production environments
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.environment == "prod" ? [] : ["0.0.0.0/0"]
    description = var.environment == "prod" ? "No outbound traffic (locked down)" : "All outbound traffic (dev/staging)"
  }

  # No public ingress ports — all management via SSM Session Manager
  # SSM uses outbound HTTPS (443) only, no inbound rules needed

  tags = {
    Name = "${var.instance_name}-sg"
  }
}

# Optional: restrict egress to specific endpoints in production
resource "aws_security_group_rule" "prod_egress_restricted" {
  count             = var.environment == "prod" ? 1 : 0
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # Restrict to VPC endpoints in real production
  security_group_id = aws_security_group.stig_instance.id
  description       = "HTTPS egress for SSM and package updates (production)"
}
