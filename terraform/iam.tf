##############################################################
# IAM Role & Instance Profile — SSM Session Manager
# Enables secure, keyless access without exposing SSH
##############################################################

# Trust policy allowing EC2 to assume the role
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM role for the EC2 instance
resource "aws_iam_role" "stig_instance_role" {
  name               = "${var.instance_name}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  description        = "IAM role for DISA STIG hardened EC2 instance with SSM access"

  tags = {
    Name = "${var.instance_name}-role"
  }
}

# Attach AmazonSSMManagedInstanceCore for Session Manager access
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.stig_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach CloudWatch agent policy for logging and monitoring
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.stig_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Custom inline policy for least-privilege S3 access to STIG reports
data "aws_iam_policy_document" "stig_reports" {
  statement {
    sid    = "PutSTIGReports"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "arn:aws:s3:::${var.instance_name}-stig-reports/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_iam_role_policy" "stig_reports" {
  name   = "stig-report-upload"
  role   = aws_iam_role.stig_instance_role.id
  policy = data.aws_iam_policy_document.stig_reports.json
}

# Instance profile
resource "aws_iam_instance_profile" "ssm" {
  name = "${var.instance_name}-profile"
  role = aws_iam_role.stig_instance_role.name
}
