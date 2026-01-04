output "bucket_name" {
  value = aws_s3_bucket.bucket.id
}

output "bucket_policy" {
  value = data.aws_iam_policy_document.bucket.json
}

output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}

output "kms_key_arn" {
  value = aws_kms_key.s3.arn
}

output "kms_key_id" {
  value = aws_kms_key.s3.id
}

output "kms_key_policy" {
  value = data.aws_iam_policy_document.kms_key_s3.json
}

output "lz_execution_iam_role_name" {
  value = aws_iam_role.lz_execution.name
}

output "lz_execution_iam_role_arn" {
  value = aws_iam_role.lz_execution.arn
}

output "org_xacct_iam_role_name" {
  value = aws_iam_role.org_xacct.name
}

output "org_xacct_iam_role_arn" {
  value = aws_iam_role.org_xacct.arn
}
