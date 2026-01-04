output "acl" {
  description = "ID of the S3 bucket ACL resource in case the object property is not BucketOwnerEnforced."
  value       = var.object_ownership == "BucketOwnerEnforced" ? null : aws_s3_bucket_acl.main
}

output "arn" {
  description = "ARN of the bucket."
  value       = aws_s3_bucket.main.arn
}

output "bucket" {
  description = "Name of the bucket."
  value       = aws_s3_bucket.main.bucket
}

output "bucket_domain_name" {
  description = "Bucket domain name. Will be of format bucketname.s3.amazonaws.com"
  value       = aws_s3_bucket.main.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket region-specific domain name. The bucket domain name including the region name."
  value       = aws_s3_bucket.main.bucket_regional_domain_name
}

output "hosted_zone_id" {
  description = "Route 53 Hosted Zone ID for this bucket's region."
  value       = aws_s3_bucket.main.hosted_zone_id
}

output "id" {
  description = "Name of the bucket."
  value       = aws_s3_bucket.main.id
}

output "policy" {
  description = " Text of the policy"
  value       = aws_s3_bucket_policy.main.policy
}

output "region" {
  description = "AWS region this bucket resides in."
  value       = aws_s3_bucket.main.region
}
