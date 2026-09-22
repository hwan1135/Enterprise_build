# Enterprise_buildYes—use Terraform for the landing zone, access model, Route 53, network, tags, ECS/Fargate, EC2, and Lambda. Do not use one monolithic Terraform state: bootstrap state first, organization/identity second, then separate state per environment. Terraform’s S3 backend supports S3-native locking with use_lockfile; bucket versioning is strongly recommended for state recovery. 
hashicorp.com

Three actions remain intentional bootstrap exceptions: root-user MFA, enabling the IAM Identity Center organization instance, and external domain-registration/delegation steps. IAM Identity Center must be enabled in one Region for the organization before Terraform can manage its permission sets and assignments. 
amazon.com
+1

Below is a Terraform baseline for:

AWS Organizations and workload accounts

IAM Identity Center groups and permission sets

Required resource tags

Route 53 public and private hosted zones

ACM certificate and DNS validation

Two-AZ VPC, NAT gateways, VPC endpoints, and flow logs

Application Load Balancer

ECS/Fargate service

EC2 Auto Scaling Group

Lambda function and EventBridge schedule

CloudWatch logs and alarms

S3 Terraform backend

1. Repository Layout
aws-enterprise-platform/
├── 00-bootstrap/
│   ├── versions.tf
│   ├── variables.tf
│   ├── main.tf
│   └── outputs.tf
├── 10-organization/
│   ├── versions.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── main.tf
│   └── outputs.tf
├── 20-identity-center/
│   ├── versions.tf
│   ├── providers.tf
│   ├── variables.tf
│   └── main.tf
├── 30-development-platform/
│   ├── versions.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── locals.tf
│   ├── network.tf
│   ├── dns.tf
│   ├── iam.tf
│   ├── ecs.tf
│   ├── ec2.tf
│   ├── lambda.tf
│   ├── monitoring.tf
│   ├── outputs.tf
│   └── lambda/
│       └── handler.py
└── terraform.tfvars.example
Use a separate state file for each directory. Do not place credentials, Terraform state, .tfvars files containing secrets, or private certificates in source control.

2. One-Time Manual Bootstrap Actions
Complete these before running Terraform:

Enable root MFA.

Create AWS Organizations in the bare account.

Enable IAM Identity Center as an organization instance in your selected home Region.

Create or delegate your approved public DNS domain.

Configure an AWS CLI profile through IAM Identity Center:

aws configure sso
aws sso login --profile platform-admin
IAM Identity Center is intended for centralized multi-account access; use IAM roles and temporary credentials rather than routine IAM users and long-lived access keys. 
amazon.com

Deployment Order
cd 00-bootstrap
terraform init
terraform apply

cd ../10-organization
terraform init
terraform apply \
  -var='account_emails={
    log_archive="aws-log-archive@example.mil",
    security="aws-security@example.mil",
    shared_services="aws-shared@example.mil",
    development="aws-development@example.mil",
    production="aws-production@example.mil"
  }'

cd ../20-identity-center
terraform init
terraform apply \
  -var="development_account_id=..." \
  -var="production_account_id=..." \
  -var="shared_services_account_id=..."

cd ../30-development-platform
terraform init
terraform plan -out=tfplan
terraform apply tfplan

Important Implementation Notes
Replace OrganizationAccountAccessRole with a more narrowly scoped Terraform deployment role after initial account bootstrap.

Restrict the ALB ingress CIDR range if the application is not intended for public internet access.

Add AWS WAF before exposing public workloads.

Add GuardDuty, Security Hub, CloudTrail, AWS Config, centralized log archive, AWS Backup, and SCPs as separate Terraform stacks rather than mixing them into application state.

Add RDS, Aurora, DynamoDB, SQS, EventBridge, Secrets Manager, and ECR repositories only after the application’s data and integration requirements are defined.

The example creates two NAT gateways for Availability Zone resilience; review cost and availability requirements before deployment.

Validate service availability, identity design, account provisioning, DNS delegation, firewall rules, security controls, and release approval requirements through the appropriate enterprise authorities before applying in a production account.