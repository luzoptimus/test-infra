module "s3bucket" {
  source = "../../modules/s3bucket"
  for_each = var.buckets

  project     = var.project
  environment = var.environment
  component   = var.component

  name = var.environment != "optimus-dev" ? "${each.key}-${var.environment}" : "${each.key}"

  object_ownership = each.value.object_ownership #"ObjectWriter"
  acl              = each.value.acl              #"log-delivery-write"

  policy_documents_1 = each.value.policies
  #kms_key_arn        = module.kms_s3_buckets.key_arn
  lifecycle_rules    = each.value.lifecycle_rules

  default_tags        = local.tags
  #aws_s3_access_point = each.value.aws_s3_access_point
  #checkov:skip=CKV2_AWS_65: "Ensure access control lists for S3 buckets are disabled"

}
#KMS for s3Bucket:
# module "kms_s3_buckets" {
#    source = "../../modules/kms"

#   project        = var.project
#   environment    = var.environment
#   component      = var.component
#   aws_account_id = var.aws_account_id
#   region         = var.region

#   alias           = "alias/s3/buckets"
#   deletion_window = "30"
#   name            = "kms-s3-buckets-${var.region}"

#   key_policy_documents = [data.aws_iam_policy_document.kms_s3_buckets.json] 

#   default_tags = local.tags
# }


# data "aws_iam_policy_document" "kms_s3_buckets" {
#   statement {
#     sid    = "AllowFullLocalAdministration"
#     effect = "Allow"

#     actions = [
#       "kms:*",
#     ]

#     resources = [
#       "*",
#     ]

#     principals {
#       type = "AWS"

#       identifiers = [
#         "arn:aws:iam::${var.aws_account_id}:root",
#       ]
#     }
#   }
#   statement {
#     sid    = "AllowArtifactsEncryptAndDecrypt"
#     effect = "Allow"
#     actions = [
#       # As required for encrypted SNS Publish
#       "kms:Decrypt",
#       "kms:GenerateDataKey",
#     ]
#     resources = [
#       "*",
#     ]
#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }
#     condition {
#       test     = "StringLike"
#       variable = "aws:PrincipalArn"
#       values = [
#         "arn:aws:iam::${var.aws_account_id}:role/application-service-*"
#       ]
#     }
#   }
# }
