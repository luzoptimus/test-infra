environment           = "optimus-dev"
avm_aws_account_name  = "optimusBrand-development"
avm_aws_account_email = "luz.penuela@optimusbrand.com"
avm_aws_account_alias = "optBra-dev"
avm_org_ou_name       = "dev"

avm_sso_associations = {
  NexusAwsPrPlatformAdmins = [ "ReadOnly" ]
}

avm_tooling = {
  deployment_admin_root_delegation = null
  deployment_execution_external_id = "95f94c7d-5199-4e2d-9318-bfc4f6bae0c5"

  github_actions = {
    enabled = false
  }

  tfscaffold = {
    enabled = false
  }

  trusted_aws_account_ids = [
    "273354644813",
  ]
}

avm_vpcs = {
  default = {
    subnets_transit                  = "9,0"
    transit_gateway_route_management = "manual"
    vpc_cidr                         = "10.194.0.0/19"
    vpc_secondary_cidrs              = "100.64.64.0/18,100.68.0.0/16,10.194.32.0/19"
    vpc_third_cidrs                  = "10.194.32.0/19" ## New CIDR  attached to transit gateway to create new cluster
  }
}

default_tags = {
  "group:account:account-type"    = "lv"

}

##
# Workload Specific Access Analyzer Archive Rules
##

avm_accessanalyzer_archive_rules = {
  "eks-deployment" = [
    {
      criteria = "isPublic"
      eq       = [ false ]
    },
    {
      criteria = "principal.AWS"

      eq = [
        "arn:aws:iam::806145550734:role/EKSDeploymentAdmin",
      ]
    },
    {
      criteria = "resource"

      contains = [
        "EKSDeploymentExecution",
      ]
    },
  ]
}

subproject = "health"
domain_name = "devel.optimusbrand.io"  ##https://optimusbrand.co
##Cognito

# username_attributes = [
#   "email", 
# ]

auto_verified_attributes = [
  "email"
]

account_recovery_mechanisms = [
  {
    name     = "verified_email"
    priority = 1
  }
]
invite_email_subject = "You've been invited to Dev Optimus"
domain               = "optimusdevel"

schema_attributes = [
  # {
  #   name       = "email",
  #   type       = "String"
  #   required   = true
  #   min_length = 1
  #   max_length = 2048
  # },
  

]

groups    = ["Administrators", "Instructors", "Integrations", "Learners"]
user_name = ["userservice@optimusbrand.com"]

passw_user_cognito = "/matterhorn/pass/userscognito"

#ECR
image_names = ["user"]