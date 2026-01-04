resource "aws_s3_access_point" "s3bucket_static_content" {
  count  = var.aws_s3_access_point ? 1 : 0
  bucket = aws_s3_bucket.main.id # module.s3bucket_static_content[0].id
  name   = var.name
}