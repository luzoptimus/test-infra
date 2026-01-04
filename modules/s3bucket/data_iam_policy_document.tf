data "aws_iam_policy_document" "main" {
  source_policy_documents = var.policy_documents

  dynamic "statement" {
    for_each = var.policy_documents_1
    content {
      sid    = statement.value.name_sid
      effect = "Allow"

      actions = statement.value.actions

      principals {
        type        = statement.value.principals_type
        identifiers = statement.value.principals_identifiers
      }

      dynamic "condition" {
        for_each = statement.value.conditions
        content {
          test     = condition.value.conditions_test
          variable = condition.value.conditions_variable
          values   = condition.value.conditions_values
        }
      }

      resources = [
        aws_s3_bucket.main.arn,
        "${aws_s3_bucket.main.arn}/*",
      ]
    }
  }

  statement {
    sid    = "DontAllowNonSecureConnection"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.main.arn,
      "${aws_s3_bucket.main.arn}/*",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "*",
      ]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false",
      ]
    }

  }
}
