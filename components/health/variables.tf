##
# Basic Required Variables for tfscaffold Components
##

variable "tfscaffold_bucket_prefix" {
  type        = string
  description = "The tfscaffold bucket prefix (mostly for constructing remote states)"
}

variable "project" {
  type        = string
  description = "The tfscaffold project"
}

variable "subproject" {
  type        = string
  description = "The tfscaffold subproject"
}

variable "aws_account_id" {
  type        = string
  description = "The AWS Account ID (numeric)"
}

variable "region" {
  type        = string
  description = "The AWS Region"
}

variable "group" {
  type        = string
  description = "The group variables are being inherited from (often synonmous with account short-name)"
  default     = ""
}

variable "environment" {
  type        = string
  description = "The environment variables are being inherited from"
}


##
# tfscaffold variables specific to this component
##

# This is the only primary variable to have its value defined as
# a default within its declaration in this file, because the variables
# purpose is as an identifier unique to this component, rather
# then to the environment from where all other variables come.
variable "component" {
  type        = string
  description = "The variable encapsulating the name of this component"
  default     = "develop"
}

variable "default_tags" {
  type        = map(string)
  description = "A map of default tags to apply to all taggable resources within the component"
  default     = {}
}

##
# AWS Organizations
##

variable "org_security_xacct_role_name" {
  type        = string
  description = "The IAM role name used by the security account to access other accounts"
  default     = "OrgSecurityCrossAccount"
}

variable "org_xacct_role_name" {
  type        = string
  description = "Name to use for the AWs Organizations default Cross Account Role. Don't ever change!"
  default     = "OrgPrimaryCrossAccount"
}

variable "org_xacct_external_id" {
  type        = string
  description = "The External ID to use with the cross-account role"
  default     = "Fahrvergnugen"
}

##
# AVM
##

variable "avm_aws_account_name" {
  type        = string
  description = "The name of the AVM-vended account"
}

variable "avm_aws_account_email" {
  type        = string
  description = "The e-mail address of the AVM-vended account"
}

variable "avm_aws_account_alias" {
  type        = string
  description = "The IAM Account Alias of the AVM-vended acccount"
  default     = null
}

variable "avm_aws_account_subdomains" {
  type        = set(string)
  description = "The subdomains delegated from the primary account of the AVM-vended account. Usually a singular value the same as the account name or alias"
  default     = []
}

variable "avm_aws_account_ses_subdomains" {
  type        = set(string)
  description = "The subdomains for which to enable AWS SES"
  default     = []
}

variable "avm_org_ou_name" {
  type        = string
  description = "Name of the AWS Organizations Organizational Unit to attache the AWS Account to"
  default     = "avm"
}

variable "avm_vpcs" {
  type        = map(map(string))
  description = "AVM VPC Configurations"
  default     = {}
}

variable "avm_tooling" {
  type = object({
    deployment_admin_root_delegation = bool
    deployment_execution_external_id = string

    github_actions = object({
      enabled              = bool
      oidc_thumbprint_list = optional(list(string))
      subject_claims       = optional(list(string))
    })

    tfscaffold = object({
      enabled = bool
      project = optional(string)
    })

    trusted_aws_account_ids = list(string)
  })

  description = "Configuration for AVM Tooling"

  default = {
    deployment_admin_root_delegation = true
    deployment_execution_external_id = null

    github_actions = {
      enabled = false
    }

    tfscaffold = {
      enabled = false
      project = null
    }

    trusted_aws_account_ids = []
  }
}

##
# Guardrails
##

variable "awssupport_iam_role" {
  type = object({
    # Custom JSON Trust Policy - default is to trust the local root principal
    custom_trust_policy = string

    # Whether to create the role
    enable = bool

    # Whether to create an Organizations Service Control Policy that restricts CreateCase only to this role
    exclusive_create_access = bool

    # Static name to give to the role
    name = string
  })

  description = "Configuration for the CIS AWS Foundations 1.20 AWS Support IAM Role"

  default = {
    custom_trust_policy     = null
    enable                  = false
    exclusive_create_access = false
    name                    = "AwsSupport"
  }
}

variable "avm_detective_enable" {
  type        = bool
  description = "Whether to include this account in the org detective graph"
  default     = true
}

variable "avm_guardduty_local_publish" {
  type        = bool
  description = "Whether to publish GuardDuty events to a local S3 bucket per region"
  default     = false
}

variable "avm_config_configuration_recorder_name" {
  type        = string
  description = "Optional custom name for the configuration recorder in all regions. ALWAYS USE THE DEFAULT!"
  default     = "default"
}

variable "avm_config_sns_delivery" {
  type        = bool
  description = "Whether to publish Config events to an SNS topic per region"
  default     = false
}

variable "avm_destructive_guardrails" {
  type        = map(bool)
  description = "Map of optional destructive guardrails to toggle for each AVM"

  default = {
    detach_direct_policies = true
    expunge_default_vpcs   = true
  }
}

variable "cloudtrail_event_selectors" {
  # Can't handle sets with multiple types
  #type        = set(any)
  description = "Event selectors for enabling data event logging. See: https://www.terraform.io/docs/providers/aws/r/cloudtrail.html for details"

  default = [
    {
      read_write_type           = "All"
      include_management_events = true

      # Example service exclusion:
      # exclude_management_event_sources = [
      #   "kms.amazonaws.com",
      #   "rdsdata.amazonaws.com",
      # ]

      data_resource = [
        {
          type   = "AWS::S3::Object"
          values = ["arn:aws:s3:::"]
        },
        {
          type   = "AWS::Lambda::Function"
          values = ["arn:aws:lambda"]
        },
      ]
    },
  ]
}

variable "cloudtrail_cloudwatch_log_retention_in_days" {
  type        = number
  description = "The number of days to retain Cloudtrail CloudWatch Logs"
  default     = 365
}

variable "guardduty_finding_publishing_frequency" {
  type        = string
  description = "The AWS GuardDuty finding publishing frequency (AWS Default: SIX_HOURS}"
  default     = "SIX_HOURS"
}

variable "s3_account_public_access_block" {
  type        = map(bool)
  description = "Map of S3 Public Access Block settings to apply account-wide"

  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

variable "securityhub_disabled_standards_controls" {
  type        = map(string)
  description = "Map of Disabled SecurityHub Standards Controls for all Active Regions in all accounts to the reason for their disablement"

  default = {

    # Defaults for All Accounts including Primary/Core

    "aws-foundational-security-best-practices/v/1.0.0/CloudFront.2" = "Origin Access Identity has been superseded by Origin Access Control"
    "aws-foundational-security-best-practices/v/1.0.0/CloudFront.4" = "Origin Failover is not required for single-region s3-origin deployments"
    "aws-foundational-security-best-practices/v/1.0.0/DynamoDB.1"   = "DynamoDB Table scaling choices are subject to architectural requirements"
    "aws-foundational-security-best-practices/v/1.0.0/EC2.10"       = "A VPC with no EC2 instances, should not have an unnecessary and expensive EC2 VPC Interface Endpoint"
    "aws-foundational-security-best-practices/v/1.0.0/EC2.17"       = "There are many reasons for an EC2 instance to be multi-homed"
    "aws-foundational-security-best-practices/v/1.0.0/EC2.21"       = "Network ACLs are only used for explicit source exclusion"
    "aws-foundational-security-best-practices/v/1.0.0/ECR.2"        = "ECR Image Tag Immutability is *not* a security requirement and breaks 'latest'"
    "aws-foundational-security-best-practices/v/1.0.0/ELB.6"        = "Deletion Protection for ALBs has little value and is a barrier to idempotency"
    "aws-foundational-security-best-practices/v/1.0.0/IAM.21"       = "Appropriate for many services, e.g. wellarchitected:*"
    "aws-foundational-security-best-practices/v/1.0.0/KMS.2"        = "Unavoidable when using AdministratorAccess and AWS SSO. To be reviewed as IDAM models change in future"
    "aws-foundational-security-best-practices/v/1.0.0/S3.10"        = "Only Buckets with a functional requirement should have Lifecycle Policies"
    "aws-foundational-security-best-practices/v/1.0.0/S3.11"        = "Only Buckets with a functional requirement should have Object Notifications"
    "aws-foundational-security-best-practices/v/1.0.0/S3.13"        = "Only Buckets containing qualifying data should have lifecycle policies; not account-wide"

    "cis-aws-foundations-benchmark/v/1.2.0/1.13" = "Virtual MFA is not required due to the break glass process"
    "cis-aws-foundations-benchmark/v/1.2.0/3.1"  = "Alert Fatigue - See GuardDuty"
    "cis-aws-foundations-benchmark/v/1.2.0/3.2"  = "Alert Fatigue - See GuardDuty"
    "cis-aws-foundations-benchmark/v/1.2.0/3.4"  = "Alert Fatigue - See GuardDuty"
    "cis-aws-foundations-benchmark/v/1.2.0/3.7"  = "Alert Fatigue - See GuardDuty"
    "cis-aws-foundations-benchmark/v/1.2.0/3.8"  = "Alert Fatigue - See GuardDuty"
    "cis-aws-foundations-benchmark/v/1.2.0/3.10" = "Alert Fatigue - See GuardDuty"
    "cis-aws-foundations-benchmark/v/1.2.0/3.11" = "Alert Fatigue - See GuardDuty"
    "cis-aws-foundations-benchmark/v/1.2.0/3.12" = "Alert Fatigue - See GuardDuty"
    "cis-aws-foundations-benchmark/v/1.2.0/3.13" = "Alert Fatigue - See GuardDuty"
    "cis-aws-foundations-benchmark/v/1.2.0/3.14" = "Alert Fatigue - See GuardDuty"

    "cis-aws-foundations-benchmark/v/1.4.0/1.17" = "IAM Role for AWS Support is only required for partner-led support"
    "cis-aws-foundations-benchmark/v/1.4.0/4.4"  = "Alert Fatigue - See GuardDuty"
    "cis-aws-foundations-benchmark/v/1.4.0/4.7"  = "Alert Fatigue - See GuardDuty"
    "cis-aws-foundations-benchmark/v/1.4.0/4.8"  = "Alert Fatigue - See GuardDuty"
    "cis-aws-foundations-benchmark/v/1.4.0/4.10" = "Alert Fatigue - See GuardDuty"
    "cis-aws-foundations-benchmark/v/1.4.0/4.11" = "Alert Fatigue - See GuardDuty"
    "cis-aws-foundations-benchmark/v/1.4.0/4.12" = "Alert Fatigue - See GuardDuty"
    "cis-aws-foundations-benchmark/v/1.4.0/4.13" = "Alert Fatigue - See GuardDuty"
    "cis-aws-foundations-benchmark/v/1.4.0/4.14" = "Alert Fatigue - See GuardDuty"
    "cis-aws-foundations-benchmark/v/1.4.0/5.1"  = "Network ACLs are only used for explicit source exclusion"

    "nist-800-53/v/5.0.0/CloudFront.2" = "Origin Access Identity has been superseded by Origin Access Control"
    "nist-800-53/v/5.0.0/CloudFront.4" = "Origin Failover is not required for single-region s3-origin deployments"
    "nist-800-53/v/5.0.0/DynamoDB.1"   = "DynamoDB Table scaling choices are subject to architectural requirements"
    "nist-800-53/v/5.0.0/DynamoDB.4"   = "DynamoDB Tables should only be in a backup plan if they store persistent data"
    "nist-800-53/v/5.0.0/EC2.10"       = "A VPC with no EC2 instances, should not have an unnecessary and expensive EC2 VPC Interface Endpoint"
    "nist-800-53/v/5.0.0/EC2.17"       = "There are many reasons for an EC2 instance to be multi-homed"
    "nist-800-53/v/5.0.0/EC2.21"       = "Network ACLs are only used for explicit source exclusion"
    "nist-800-53/v/5.0.0/EC2.28"       = "EC2 volumes should only be in a backup plan if they store persistent data"
    "nist-800-53/v/5.0.0/ECR.2"        = "ECR Image Tag Immutability is *not* a security requirement and breaks 'latest'"
    "nist-800-53/v/5.0.0/ELB.6"        = "Deletion Protection is a barrier to idempotency"
    "nist-800-53/v/5.0.0/IAM.9"        = "Virtual MFA is not used for Root user accounts"
    "nist-800-53/v/5.0.0/IAM.21"       = "Appropriate for many services, e.g. wellarchitected:*"
    "nist-800-53/v/5.0.0/KMS.2"        = "Unavoidable when using AdministratorAccess and AWS SSO. To be reviewed as IDAM models change in future"
    "nist-800-53/v/5.0.0/Lambda.3"     = "Only Lambda functions handling qualifying data should be in VPC; not account-wide"
    "nist-800-53/v/5.0.0/S3.7"         = "Only Buckets containing qualifying data should be multi-region replicated; not account-wide"
    "nist-800-53/v/5.0.0/S3.10"        = "Only Buckets containing qualifying data should have lifecycle policies; not account-wide"
    "nist-800-53/v/5.0.0/S3.11"        = "Only Buckets with a functional requirement should be multi-region replicated; not account-wide"
    "nist-800-53/v/5.0.0/S3.13"        = "Only Buckets containing qualifying data should have lifecycle policies; not account-wide"
    "nist-800-53/v/5.0.0/S3.15"        = "Only Buckets containing qualifying data should have Object Lock; not account-wide"

    "pci-dss/v/3.2.1/PCI.IAM.5"    = "Virtual MFA is not required due to the break glass process"
    "pci-dss/v/3.2.1/PCI.Lambda.3" = "Only Lambda functions handling qualifying data should be in VPC; not account-wide"
    "pci-dss/v/3.2.1/PCI.S3.7"     = "Only Buckets containing qualifying data should be multi-region replicated; not account-wide"

    # Defaults for Vended Accounts

    "aws-foundational-security-best-practices/v/1.0.0/IAM.6"            = "Hardware MFA is only enabled in the Primary account"
    "aws-foundational-security-best-practices/v/1.0.0/SecretsManager.1" = "Auto rotation is not possible in nexus as the secrets are externally supplied via manual process"
    "aws-foundational-security-best-practices/v/1.0.0/SecretsManager.4" = "Auto rotation is not possible in nexus as the secrets are externally supplied via manual process"

    "cis-aws-foundations-benchmark/v/1.2.0/1.14" = "Hardware MFA is only enabled in the Primary account"
    "cis-aws-foundations-benchmark/v/1.2.0/2.3"  = "CloudTrail Bucket is in the Audit Account so cannot be tested here"
    "cis-aws-foundations-benchmark/v/1.2.0/2.6"  = "CloudTrail Bucket is in the Audit Account so cannot be tested here"

    "cis-aws-foundations-benchmark/v/1.4.0/1.5" = "Root MFA is only required in the primary account"
    "cis-aws-foundations-benchmark/v/1.4.0/1.6" = "Root Hardware MFA is only required in the primary account"
    "cis-aws-foundations-benchmark/v/1.4.0/3.3" = "Can only be asserted in the Audit account"
    "cis-aws-foundations-benchmark/v/1.4.0/3.6" = "Can only be asserted in the Audit account"

    "nist-800-53/v/5.0.0/IAM.6"            = "Hardware MFA is only required for the primary account"
    "nist-800-53/v/5.0.0/SecretsManager.1" = "Auto rotation is not possible in nexus as the secrets are externally supplied via manual process"
    "nist-800-53/v/5.0.0/SecretsManager.4" = "Auto rotation is not possible in nexus as the secrets are externally supplied via manual process"

    "pci-dss/v/3.2.1/PCI.IAM.4" = "Hardware MFA is only enabled in the Primary account"
  }
}

variable "avm_securityhub_disabled_standards_controls" {
  type        = map(string)
  description = "Map of Disabled SecurityHub Standards Controls for this AVM Account to the reason for their disablement"
  default     = {}
}

variable "securityhub_standards_controls_lambda_function_name" {
  type        = string
  description = "Static name to use for the security hub controls management lambda"
  default     = "SecHubStdsControlsManager"
}

##
# IAM
##

##
# avm_user_groups for each account will create groups as specified, and for each
# user specified as a member of one or more groups will also create the user
# and attach them to the group.
#
# avm_user_groups = {
#   "Administrators" = [
#     "user.one@example.org",
#   ]
#
#   "Billing" = [
#     "user.two@example.org",
#   ]
#
#   "SimpleReadOnly" = [
#     "user.two@example.org",
#   ]
# }
#
# Only pre-defined groups in the bs-iam module will have permissions attached:
#
# * Administrators
# * Billing
# * Security
# * SensitiveReadOnly
# * SimpleReadOnly
#
variable "avm_user_groups" {
  type        = map(list(string))
  description = "Map of IAM groups to a list of IAM Users"
  default     = {}
}

# If a user exists in var.user_groups, then additional tags for specific users
# can be specified here like this:
#
# avm_user_tags = {
#   "user.one@example.org" = {
#     TagKeyOne = "TagValueOne"
#     TagKeyTwo = "TagValueTwo"
#   }
# }
#
variable "avm_user_tags" {
  type        = map(map(string))
  description = "Map of users to a map of additional tags for the user"
  default     = {}
}

variable "prisma_cloud" {
  type = object({
    enabled     = bool
    account_id  = string
    external_id = string
  })

  description = "Configuration for Prisma Cloud"

  default = {
    enabled     = false
    account_id  = ""
    external_id = ""
  }
}

##
# KMS Delete Alerts
##

variable "kms_delete_alerts" {
  type = object({
    enabled                        = bool
    sns_topic_external_subscribers = list(map(string))
  })

  description = "KMS Delete Alerts feature configuration"

  default = {
    enabled                        = false
    sns_topic_external_subscribers = null
  }
}

##
# Lambda
##

variable "lambda_dlq_targets" {
  type        = list(map(string))
  description = "Targets to subscribe to the lambda SNS topic (usually DLQ)"
  default     = []
}

##
# Logging
##

variable "avm_cloudwatch_firehose_config" {
  type = map(object({
    include_pattern          = string
    exclude_pattern          = string
    subscription_filter_name = string
    log_type                 = string
  }))

  description = "Configuration of Logs to include in the Cloudwatch Logs Firehose delivering to the Organization Audit account"
  default     = {}
}

variable "avm_cloudwatch_firehose_enable" {
  type        = bool
  description = "Whether to enable log replication from CloudWatch to the Audit account"
  default     = false
}

variable "avm_vpc_flow_s3_delivery" {
  type        = bool
  description = "Whether to enable VPC flow log delivery to S3."
  default     = false
}

##
# Cloud Conformity
##

variable "cloud_conformity" {

  type = object({
    external_id        = string
    role_name          = string
    trusted_account_id = string
  })

  description = "Configuration for Cloud Conformity integration"

  default = null
}

##
# Alternate Account Contacts
##

# Example:
# default_alternate_account_contacts = {
#   billing = {
#     email_address = "billing-contact@example.org"
#     name          = "Billing Contact Name"
#     phone_number  = "+440000000000"
#     title         = "."
#   }

variable "default_alternate_account_contacts" {
  description = "Map of Maps of Default AWS Account Alternate Contact details. Specify up to one each of security, operations and billing"
  type        = map(map(string))
  default     = {}
}

variable "avm_alternate_account_contacts" {
  description = "Map of Maps of AWS Account Alternate Contact details for the AVM Vended Account. Specify up to one each of security, operations and billing"
  type        = map(map(string))
  default     = {}
}

##
# Cloud Health
##

variable "cloud_health" {

  type = object({
    external_id        = string
    role_name          = string
    trusted_account_id = string
  })

  description = "Configuration for Cloud Health integration"

  default = null
}

##
# SSO
##

# Make it possible to disable SSO per AVM
variable "avm_sso_enable" {
  type        = bool
  description = "Whether SSO functionality is enabled for the AVM"
  default     = true
}

# example:
# avm_sso_associations = {
#    MyAdGroup = ["MyOtherPermissionSet"]
#}
# This map is merged with the default_sso_associations
# map for any overrides, then is looped over and every group
# identified is linked to each permission set in the
# associated list
variable "avm_sso_associations" {
  type        = map(list(string))
  description = "Map of groups to SSO permission set names"
  default     = {}
}

# example:
# default_sso_associations = {
#    MyAdGroup = ["MyPermissionSet"]
#}
# This map is looped over, every group identified and
# linked to each permission set in the associated list
# This map is used as a default for every account.
variable "default_sso_associations" {
  type        = map(list(string))
  description = "Map of default groups to SSO permission set names"
  default     = {}
}

##
# Cross Account Cloudwatch Dashboards
##

variable "cloudwatch_crossaccount_enable" {
  type        = bool
  description = "Toggle for allowing cross-account CW dashboards"
  default     = true
}

##
# Route53 Backup
##

variable "route53_backup_xacct_role_name" {
  type        = string
  description = "Name of the cross-account role for Route53 Backups. Also the feature toggle"
  default     = null
}

##
# Access Analyzer
##

variable "accessanalyzer_archive_rules" {
  type = map(set(object({
    criteria = string
    contains = optional(list(string))
    eq       = optional(list(string))
    exists   = optional(bool)
    neq      = optional(list(string))
  })))

  description = "Map of set of objects describing shared AWS Access Analyzer Archive Rules"

  default = {
    "xacct-sso-roles" = [
      {
        criteria = "isPublic"
        eq       = ["false"]
      },
      {
        criteria = "principal.Federated"

        contains = [
          ":saml-provider/AWSSSO",
        ]
      },
    ]
  }
}

variable "avm_accessanalyzer_archive_rules" {
  type = map(set(object({
    criteria = string
    contains = optional(list(string))
    eq       = optional(list(string))
    exists   = optional(bool)
    neq      = optional(list(string))
  })))

  description = "Map of set of objects describing AWS Access Analyzer Archive Rules specifically for this account"
  default     = {}
}

##
# Centralised DNS Resolver Endpoints
##

variable "centralised_dns_enabled" {
  type        = bool
  description = "Whether to enable centralised DNS control and Route53 Resolver Endpoints"
  default     = false
}

##
# ECR
##

variable "avm_ecr" {
  type = object({
    default_scan_frequency = string

    additional_scan_rules = set(object({
      filter_string  = string
      scan_frequency = string
    }))
  })

  description = "ECR Registry Scanning Configuration"

  default = {
    default_scan_frequency = "CONTINUOUS_SCAN"
    additional_scan_rules  = []
  }
}

variable "qualys_connector" {
  type = object({
    account_id  = string
    external_id = string
  })

  description = "Account and external ID for the Qualys connector role trust policy"
  default     = null
}

#cognito
variable "attributes_user" {
  type        = map(string)
  description = "The username for the user. Must be unique within the user pool. Must be a UTF-8 string between 1 and 128 characters. After the user is created, the username cannot be changed."
  default     = {}
}

#pool_client

variable "access_token_validity"  {
  type = number
  description = "Time limit, between 5 minutes and 1 day"
  default = 240
  }   

variable "id_token_validity"  {
  type = number
  description = "Time limit, between 5 minutes and 1 day"
  default = 240
  }  

variable "user_device_tracking" {
  type        = string
  description = "(Optional) Configure tracking of user devices. Set to 'OFF' to disable tracking, 'ALWAYS' to track all devices or 'USER_OPT_IN' to only track when user opts in."
  default     = "OFF"
}

variable "auto_verified_attributes" {
  type        = set(string)
  description = "(Optional) The attributes to be auto-verified. Possible values: 'email', 'phone_number'."
  default = [
    "email"
  ]
}

variable "account_recovery_mechanisms" {
  type        = any
  description = "(Optional) A list of recovery_mechanisms which are defined by a `name` and its `priority`. Valid values for `name` are veri  fied_email, verified_phone_number, and admin_only."
  # Example:
  #
  # account_recovery_setting_recovery_mechanisms = [
  #   {
  #     name          = "verified_email"
  #     priority      = 1
  #   },
  #   {
  #     name          = "verified_phone_number"
  #     priority      = 2
  #   }
  # ]
  default = []
}

variable "invite_email_subject" {
  type        = string
  description = "(Optional) The subject for email messages."
  default     = "Your new account."
}

variable "domain" {
  description = "(Optional) Type a domain prefix to use for the sign-up and sign-in pages that are hosted by Amazon Cognito, e.g. 'https://{YOUR_PREFIX}.auth.eu-west-1.amazoncognito.com'. The prefix must be unique across the selected AWS Region. Domain names can only contain lower-case letters, numbers, and hyphens."
  type        = string
  default     = null
}

variable "domain_name" {
  description = "(Optional) Type a domain prefix to use for the sign-up and sign-in pages that are hosted by Amazon Cognito, e.g. 'https://{YOUR_PREFIX}.auth.eu-west-1.amazoncognito.com'. The prefix must be unique across the selected AWS Region. Domain names can only contain lower-case letters, numbers, and hyphens."
  type        = string
  default     = null
}

variable "schema_attributes" {
  description = "(Optional) A list of schema attributes of a user pool. You can add a maximum um 25 custom attributes."
  type        = any

  default = []
}

variable "clients" {
  description = "(Optional) A list of objects with the clients definitions."
  type        = any
  default = []
}
variable "groups" {
  description = "(Optional) groups name - cognito pool"
  type        = list(string)
  default     = []
}

variable "user_name" {
  type        = list
  description = "(Optional) The username for the user. Must be unique within the user pool. Must be a UTF-8 string between 1 and 128 characters. After the user is created, the username cannot be changed."
  default     = []
}

variable "user_email" {
  type        = list
  description = "(Optional) The username for the user. Must be unique within the user pool. Must be a UTF-8 string between 1 and 128 characters. After the user is created, the username cannot be changed."
  default     = []
}

variable "generate_secret" {
  type        = bool
  default     = false
  description = "Set to false to generate secret user pool"
}
variable "default_client_supported_identity_providers" {
  description = "(Optional) List of provider names for the identity providers that are supported on this client."
  type        = list(string)
  default     = ["COGNITO"]
}

variable "username_attributes" {
  type        = set(string)
  description = "(Optional) Specifies whether email addresses or phone numbers can be specified as usernames when a user signs up. Conflicts with alias_attributes."
  default     = null
}

variable "image_names" {
  type        = list(string)
  default     = []
  description = "List of Docker local image names, used as repository names for AWS ECR "
}

variable "client_id_google" {
  type        = string
  default     = ""
  description = "identity provider client_id_google"
}

variable "client_secret_google" {
  type        = string
  default     = ""
  description = "identity provider client_secret_google"
}