environment           = "qa"
avm_aws_account_name  = "optimusBrand-development"
avm_aws_account_email = "luz.penuela@optimusbrand.com"
# avm_aws_account_alias = "optBra-qa"
# avm_org_ou_name       = "qa"

# avm_sso_associations = {
#   NexusAwsPrPlatformAdmins = [ "ReadOnly" ]
# }

# avm_tooling = {
#   deployment_admin_root_delegation = null
#   deployment_execution_external_id = "95f94c7d-5199-4e2d-9318-bfc4f6bae0c5"

#   github_actions = {
#     enabled = false
#   }

#   tfscaffold = {
#     enabled = false
#   }

#   trusted_aws_account_ids = [
#     "273354644813",
#   ]
# }

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
domain_name = "qa.optimusbrand.io"  ##https://optimusbrand.co

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
invite_email_subject = "You've been invited to QA Optimus"
domain               = "optimusqa"

schema_attributes = [
  {
    name       = "user_id",
    type       = "String"
    required   = false
    min_length = 1
    max_length = 256
  },
  {
    name       = "full_name",
    type       = "String"
    required   = false
    min_length = 1
    max_length = 256
  },
  ]

groups    = ["patients", "practitioners"]
user_email = ["userservice@optimusbrand.com"]
user_name = ["luz.penuela"]
passw_user_cognito = "/matterhorn/pass/userscognito"

#ECR
image_names = [] #"user", "application"

#ECS
ecs_services = {
  user-service = {
    name          = "user-service"
    desired_count = 2

    # Load Balancer - Path-based routing
    container_name = "user"
    container_port = 8080
    path_patterns  = ["/ouc-api/*"]

    containers = {
      user = {
        image                    = "273354644813.dkr.ecr.us-west-2.amazonaws.com/optimus/backend/user:develop-a8eb2e5"
        readonly_root_filesystem = false
        essential                = true

        port_mappings = [{
          name          = "user"
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }]

        mount_points = [{
          sourceVolume  = "ebs-volume"
          containerPath = "/data"
        }]

        entrypoint = ["dotnet", "Oss.User.WebAPI.dll"]

        enable_cloudwatch_logging              = true
        create_cloudwatch_log_group            = true
        cloudwatch_log_group_retention_in_days = 7

        environment = [
          {
            name  = "AWS_REGION"
            value = "us-west-2"
          },
          {
            name  = "ASPNETCORE_ENVIRONMENT"
            value = "Development"
          }
        ]
      }
    }
  }

  application-service = {
    name          = "application-service"
    desired_count = 1

    container_name = "application"
    container_port = 8080
    path_patterns  = ["/oac-api/*"]

    containers = {
      application = {
        image     = "273354644813.dkr.ecr.us-west-2.amazonaws.com/optimus/backend/application:develop-36cabf7"
        essential = true

        port_mappings = [{
          name          = "application"
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }]

        mount_points = [{
          sourceVolume  = "ebs-volume"
          containerPath = "/data"
        }]

        entrypoint = ["dotnet", "Oss.Application.WebAPI.dll"]

        environment = [
          {
            name  = "AWS_REGION"
            value = "us-west-2"
          }
        ]
      }
    }
  }
}

buckets = {
    optimus-healthcare-secure-data = {
      acl = "public"
      policies = []
  }
}