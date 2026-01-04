locals{
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${format("%s-%s-s3-cloudtrail-%s", var.namespace, var.environment, var.project)}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${format("%s-%s-s3-cloudtrail-%s", var.namespace, var.environment, var.project)}/AWSLogs/${var.aws_account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_cloudwatch_log_group" "backuping_cloudwatch_log_group" {
  count = var.enable_cw_logs && var.region == "us-east-1" ? 1 : 0
  name = format("%s-%s-cwlogs-cloudtrail-%s", var.namespace, var.environment, var.project)
  tags =  var.tags
  }

resource "aws_cloudwatch_log_stream" "backuping_cloudwatch_log_stream" {
  count = var.enable_cw_logs && var.region == "us-east-1" ? 1 : 0
  log_group_name = aws_cloudwatch_log_group.backuping_cloudwatch_log_group[0].id
  name = format("%s_CloudTrail_us-east-1", var.aws_account_id)
  depends_on = [aws_cloudwatch_log_group.backuping_cloudwatch_log_group]
}

resource "aws_iam_policy" "backuping_cloudtrail_cloudwatch_policy" {
  count = var.enable_cw_logs && var.region == "us-east-1" ? 1 : 0
  name        = format("%s-%s-poli-cwcloudtrail-%s", var.namespace, var.environment, var.project)
  description = "Policy to enable ClodTrail logging into CloudWatch on ${var.project}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailCreateLogStream",
      "Effect": "Allow",
      "Action": [
         "logs:CreateLogStream" 
      ],
      "Resource": [
        "${aws_cloudwatch_log_stream.backuping_cloudwatch_log_stream[0].arn}*"
      ]
    },
    {
      "Sid": "AWSCloudTrailPutLogEvents20141101",
      "Effect": "Allow",
      "Action": [
        "logs:PutLogEvents"
      ],
      "Resource": [
        "${aws_cloudwatch_log_stream.backuping_cloudwatch_log_stream[0].arn}*"
      ]
    }
  ]
}
POLICY

  depends_on = [aws_cloudwatch_log_stream.backuping_cloudwatch_log_stream]
}
##"logs:CreateLogStream"
resource "aws_iam_role" "backuping_cloudtrail_cloudwatch_role" {
  count = var.enable_cw_logs && var.region == "us-east-1" ? 1 : 0
  name = format("%s-%s-role-cwcloudtrail-%s", var.namespace, var.environment, var.project)
  path = "/service-role/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = var.tags

  depends_on = [aws_iam_policy.backuping_cloudtrail_cloudwatch_policy]
}

resource "aws_iam_role_policy_attachment" "backuping_cloudtrail_cloudwatch_role_policy_attachement" {
  count = var.enable_cw_logs && var.region == "us-east-1" ? 1 : 0
  role       = aws_iam_role.backuping_cloudtrail_cloudwatch_role[0].name
  policy_arn = aws_iam_policy.backuping_cloudtrail_cloudwatch_policy[0].arn

  depends_on = [aws_iam_role.backuping_cloudtrail_cloudwatch_role]
}


resource "aws_s3_bucket" "backuping_logs_bucket" {
  count = var.enable_cw_logs && var.region == "us-east-1" ? 1 : 0
  bucket = format("%s-%s-s3-cloudtrail-%s", var.namespace, var.environment, var.project)
  force_destroy = true

  tags = var.tags
}

resource "aws_s3_bucket_acl" "example_bucket_acl" {
  count = var.enable_cw_logs && var.region == "us-east-1" ? 1 : 0
  bucket = aws_s3_bucket.backuping_logs_bucket[0].id
  acl    = "private"
}


resource "aws_s3_bucket_policy" "default" {
  count = var.enable_cw_logs && var.region == "us-east-1" ? 1 : 0
  bucket     = aws_s3_bucket.backuping_logs_bucket[0].id
  policy     = local.policy
  depends_on = [aws_s3_bucket_public_access_block.s3_logs_bucket_public_access]
}


resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  count = var.enable_cw_logs && var.region == "us-east-1" ? 1 : 0
  bucket = aws_s3_bucket.backuping_logs_bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_logs_bucket_public_access" {
  count = var.enable_cw_logs && var.region == "us-east-1" ? 1 : 0
  bucket = aws_s3_bucket.backuping_logs_bucket[0].id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}


resource "aws_cloudtrail" "backuping_cloudtrail" {
  count = var.enable_cw_logs && var.region == "us-east-1" ? 1 : 0
  name = format("%s-%s-cwlogs-cloudtrail-%s", var.namespace, var.environment, var.project) ##"backuping-${var.env}-cloudtrail"
  s3_bucket_name = aws_s3_bucket.backuping_logs_bucket[0].id
  is_multi_region_trail = true
  enable_log_file_validation = true

  event_selector {
    read_write_type           = "All"
    include_management_events = false

    data_resource {
      type = "AWS::S3::Object"

      # Make sure to append a trailing '/' to your ARN if you want
      # to monitor all objects in a bucket.
      values = ["arn:aws:s3"]

    }
  }

  tags = var.tags

  cloud_watch_logs_role_arn = aws_iam_role.backuping_cloudtrail_cloudwatch_role[0].arn
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.backuping_cloudwatch_log_group[0].arn}:*"

  depends_on = [
    aws_iam_role_policy_attachment.backuping_cloudtrail_cloudwatch_role_policy_attachement,
    aws_s3_bucket.backuping_logs_bucket
  ]
}


resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
  count = var.enable_cw_logs && var.region == "us-east-1" ? 1 : 0
  bucket =aws_s3_bucket.backuping_logs_bucket[0].bucket

  rule {
    id = "log"

    expiration {
      days = 180
    }

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }

}