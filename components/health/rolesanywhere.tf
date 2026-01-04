
data "aws_iam_policy_document" "assume_role_dev" {
 
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
      "sts:SetSourceIdentity"
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["rolesanywhere.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      values   = [module.developer_anywhere_role.awtrust_arn]
      variable = "aws:SourceArn"
    }
  }
}

data "aws_iam_policy_document" "permissions_sns_kms_secret" {
  statement {

    actions = [
      "sns:*",
    ]

    effect = "Allow"

    resources = [
      "*",
    ]
  }
  statement {

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant",
      "kms:RetireGrant"
    ]

    effect = "Allow"

    resources = [
      "*", ##${var.kms_cloudhsm == "" ? module.kms_key.key_arn : var.kms_cloudhsm}
    ]
  }
  statement {

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    effect = "Allow"

    resources = [
      "*",
    ]
  }
}

module "developer_anywhere_role" {
  source                  = "../../modules/role"
  region                  = var.region
  namespace               = "opt"
  environment             = var.environment
  project                 = var.project
  assume_role_policy      = data.aws_iam_policy_document.assume_role_dev.json
  aws_iam_policy_document = [data.aws_iam_policy_document.permissions_sns_kms_secret.json]
  policy_arn              = ["arn:aws:iam::aws:policy/AmazonSNSFullAccess", "arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/AmazonCognitoPowerUser", "arn:aws:iam::aws:policy/AmazonSQSFullAccess", "arn:aws:iam::aws:policy/SecretsManagerReadWrite"]
  type                    = "developer"
  tags                    = local.tags
  aws_account_id          = var.aws_account_id
  #kms_key_id              = module.kms_key.key_arn 
  enabled_anywhere        = true #var.environment == "dev" ? true : false
  enable                  = true #var.environment == "dev" ? true : false
}

# module "salesforce_anywhere_role" {
#   source                  = "../terraform-modules/role"
#   region                  = var.region
#   namespace               = var.namespace
#   environment             = var.environment
#   project                 = var.project
#   assume_role_policy      = data.aws_iam_policy_document.assume_role_dev.json
#   aws_iam_policy_document = [data.aws_iam_policy_document.salesforce.json]
#   type                    = "salesforce"
#   tags                    = var.tags
#   aws_account_id          = var.aws_account_id_project
#   kms_key_id              = module.kms_key.key_arn 
#   enabled_anywhere        = var.enabled_global
#   enable                  = var.enabled_global
# }


# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Principal": {
#                 "Service": "rolesanywhere.amazonaws.com"
#             },
#             "Action": [
#                 "sts:AssumeRole",
#                 "sts:TagSession",
#                 "sts:SetSourceIdentity"
#             ],
#             "Condition": {
#                 "StringEquals": {
#                     "aws:PrincipalTag/x509Subject/OU": "Optimus"
#                 }
#             }
#         }
#     ]
# }