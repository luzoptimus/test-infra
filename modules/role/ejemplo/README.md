# ROLE



## Examples
```hcl

module "ecr_role" {
  source                  = "git::git@github.com:bdb-dns/DAPGQ-DEVOPS-TF-ROLE?ref=tags/v1.0.0"

  region                  = var.region
  namespace               = var.namespace
  environment             = var.environment
  project                 = var.project
  assume_role_policy      = data.aws_iam_policy_document.assume_role.json
  policy_arn              = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser" #ARN Politica ya creada en AWS
  type                    = "ecr"
  tags                    = var.tags
  aws_account_id          = var.aws_account_id_ecr
  }

## JSON para configurar la relacion de confianza del role
  data "aws_iam_policy_document" "assume_role" {
   statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account_id_project}:root"]
    }
  }
}

##Role assume kubenetes cluster to have permission on ALB
module "alb_ingress_role" {
  source                  = "git::git@github.com:bdb-dns/DAPGQ-DEVOPS-TF-ROLE?ref=tags/v1.0.0"                           
  region                  = var.region
  namespace               = var.namespace
  environment             = var.environment
  project                 = var.project
  assume_role_policy      = data.aws_iam_policy_document.service_account_assume_role.json
  aws_iam_policy_document = file("./iam-policy.json") ## Ubicacion de la politica en un archivo local
  type                    = "alb-ingress"
  tags                    = var.tags
  aws_account_id          = var.aws_account_id_project
  }

## JSON relationship for assume role
data "aws_iam_policy_document" "service_account_assume_role" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [format("arn:aws:iam::%s:oidc-provider/%s",  var.aws_account_id_project, local.eks_cluster_oidc_issuer)]
    }

    condition {
      test     = "StringEquals"
      values   = [format("system:serviceaccount:kube-system:alb-ingress-controller")]
      variable = format("%s:sub", local.eks_cluster_oidc_issuer)
    }
  }
} 


module "ecr_role" {
  source                  = "../"

  region                  = var.region
  namespace               = var.namespace
  environment             = var.environment
  project                 = var.project
  aws_iam_policy_document = [local.policy_sts_terraform, local.policy_sts2_terraform]
  assume_role_policy      = data.aws_iam_policy_document.service_account_assume_role.json
  policy_arn              = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
  type                    = "sts-terraform"
  tags                    = var.tags
  aws_account_id          = var.aws_account_id
  }

data "aws_iam_policy_document" "service_account_assume_role" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [format("arn:aws:iam::%s:oidc-provider/jenkins",  var.aws_account_id)]
    }

    condition {
      test     = "StringEquals"
      values   = [format("system:serviceaccount:kube-system:alb-ingress-controller")]
      variable = format("jenkins:sub")
    }
  }
} 


## Assume role politic
locals {
policy_sts_terraform = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": [
                "arn:aws:iam::780296949074:role/bdb-role-jenkins-terraform",
                "arn:aws:iam::878924158461:role/bdb-pr-role-terraform-tfstate"
            ]
        }
    ]
}
EOF

policy_sts2_terraform = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": [
                "arn:aws:iam::780296949074:role/bdb-role-jenkins-terraform",
                "arn:aws:iam::878924158461:role/bdb-pr-role-terraform-tfstate"
            ]
        }
    ]
}
EOF

}



 #example to add politc a exist role
module "ecr2_role" {
  source                  = "../"

  region                  = var.region
  namespace               = var.namespace
  environment             = var.environment
  project                 = var.project
  aws_iam_policy_document = [local.policy_sts3_terraform]
  role_name               = "bdb-role-jenkins-terraform"
  type                    = "sts-terraform1"
  tags                    = var.tags
  aws_account_id          = var.aws_account_id
  }


locals {
policy_sts3_terraform = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": [
                "arn:aws:iam::780296949074:role/bdb-role-jenkins-terraform",
                "arn:aws:iam::878924158461:role/bdb-pr-role-terraform-tfstate"
            ]
        }
    ]
}
EOF
} 

```

