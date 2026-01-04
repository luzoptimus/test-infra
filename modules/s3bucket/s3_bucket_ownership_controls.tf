resource "aws_s3_bucket_ownership_controls" "bucket_owner_enforced_main" {
  count  = var.object_ownership == "BucketOwnerEnforced" ? 1 : 0
  bucket = aws_s3_bucket.main.id

  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_ownership_controls" "main" {
  count  = var.object_ownership == "BucketOwnerEnforced" ? 0 : 1
  bucket = aws_s3_bucket.main.id

  rule {
    object_ownership = var.object_ownership
  }

  #depends_on = [aws_s3_bucket_acl.main]
}
