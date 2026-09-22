##############################################################
# Outputs
##############################################################

output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = aws_instance.stig_hardened.id
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.stig_hardened.private_ip
  sensitive   = var.environment == "prod"
}

output "instance_public_ip" {
  description = "Public IP address (if assigned)"
  value       = aws_instance.stig_hardened.public_ip
  sensitive   = true
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.stig_hardened.arn
}

output "iam_role_arn" {
  description = "IAM role ARN attached to the instance"
  value       = aws_iam_role.stig_instance_role.arn
}

output "security_group_id" {
  description = "Security group ID for the instance"
  value       = aws_security_group.stig_instance.id
}

output "kms_key_arn" {
  description = "KMS key ARN used for EBS encryption"
  value       = aws_kms_key.ebs_encryption.arn
  sensitive   = true
}

output "ssm_command" {
  description = "AWS CLI command to start an SSM Session Manager shell"
  value       = "aws ssm start-session --target ${aws_instance.stig_hardened.id} --region ${var.aws_region}"
}
