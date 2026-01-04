module "acm_certificate_ingress" {
  source = "../../modules/aws-acm-certificate"
  domain_name          = var.domain_name_acm
  private_zone         = var.private_zone
  additional_acm_names = var.additional_acm_names

  default_tags = local.tags
}

module "acm_certificate_ingress_us_east_1" {
  providers = {
    aws = aws.us_east_1
  }
  source = "../../modules/aws-acm-certificate"
  domain_name          = var.domain_name_acm
  private_zone         = var.private_zone
  additional_acm_names = var.additional_acm_names

  default_tags = local.tags
}