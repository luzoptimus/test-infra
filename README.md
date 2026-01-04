# oi.infrastructure.base

This repository implements a Terraform scaffold architecture that uses the terraform.sh script to manage infrastructure in a modular and multi-region way. The script automates backend configuration and variable selection based on environment, region, and component.

# Project Structure

oi.infrastructure.base/
├── bin/                    # Automation scripts
│   └── terraform.sh        # Main script to execute Terraform
├── bootstrap/              # Initial AWS account configuration
│   ├── s3_bucket.tf       # Bucket for tfstate
│   ├── iam_role_*.tf      # IAM Roles
│   ├── kms_key_s3.tf      # KMS encryption
│   └── ...
├── components/             # Infrastructure components by environment
│   └── health/           # Health component
│       ├── cluster-ecs.tf
│       ├── cognito.tf
│       ├── ecr.tf
│       ├── rolesanywhere.tf
│       └── s3.tf
├── etc/                    # Variable files (.tfvars)
│   ├── env_us-east-1_dev.tfvars
│   ├── env_us-west-2_dev.tfvars
│   ├── group_dev.tfvars
│   ├── us-east-1.tfvars
│   └── us-west-2.tfvars
├── modules/                # Reusable Terraform modules
│   ├── cloudfront/
│   ├── cognito/
│   ├── ecr/
│   └── role/
├── plugin-cache/          # Local cache for Terraform plugins
└── README.md
# Prerequisites

Terraform >= 1.0
AWS CLI configured with appropriate credentials
Necessary IAM permissions to create resources
Bash shell

# Usage
# Initial Bootstrap
Bootstrap must be run first to create the S3 bucket for tfstate and necessary IAM configuration:

bashbin/terraform.sh -p optimus -r us-east-1 -g dev -e dev --bootstrap --action plan
bin/terraform.sh -p optimus -r us-east-1 -g dev -e dev --bootstrap --action apply

# Deploy Components
To plan or apply changes to specific components:
bash# Plan
bin/terraform.sh -p optimus -r us-west-2 -g dev -e dev -c health --action plan

# Apply
bin/terraform.sh -p optimus -r us-west-2 -g dev -e dev -c health --action apply

# Destroy
bin/terraform.sh -p optimus -r us-west-2 -g dev -e dev -c health --action destroy

# Target
bin/terraform.sh -p optimus -r us-west-2 -g dev -e dev -c health --action plan --target "module.alb"
bin/terraform.sh -p optimus -r us-west-2 -g dev -e dev -c health --action apply --target "module.acm_certificate_ingress"
bin/terraform.sh -p optimus -r us-west-2 -g dev -e dev -c health --action plan --target "module.ecs_service"

# Backend Configuration
The terraform.sh script automatically manages Terraform backend configuration:

Uses S3 to store tfstate
State is specific per region, group, environment, and component
Implements locking with DynamoDB (configured in bootstrap)

# Variables
Variables are organized in .tfvars files within the etc/ folder:

env_{region}_{env}.tfvars: Region and environment specific variables
group_{group}.tfvars: Group variables
{region}.tfvars: Region specific variables

The script automatically loads the corresponding variables based on the provided parameters.