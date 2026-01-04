module "ecr" {
  source                 = "../../modules/ecr"
  region                 = var.region
  project                = var.project
  subproject             = "backend"
  image_names            = var.image_names
  tags                   = local.tags
  enabled                = true
  aws_account_id         = var.aws_account_id
  principals_full_access = ["arn:aws:iam::${var.aws_account_id}:root"]
  #service_full_access    = ["lambda.amazonaws.com"]
}