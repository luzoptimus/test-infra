# CLOUDFRONT


## Example


```hcl
module "cloudfront_s3_cdn" {
  source                   = "../terraform-modules/cloudfront"
  region          = var.region
  namespace       = var.namespace
  environment     = var.environment
  project         = var.project
  aws_account_id  = var.aws_account_id
  tags            = var.tags
  origin_force_destroy     = true
  enable_s3   = true
  origin_bucket      = module.bucket_olu_front.s3_bucket_id
  bucket_logs      = module.bucket_olu_logs.s3_bucket_id
  s3_bucket_domain_name  = module.bucket_olu_front.s3_bucket_domain_name
  logging_enabled          = false
}


```
