data "aws_iam_policy_document" "deployment_admin_assumerole" {
  dynamic "statement" {
    for_each = anytrue([
      var.github_actions["enabled"],
      var.deployment_admin_root_delegation,
    ]) ? [] : [1]

    content {
      sid    = "TrustNoOne"
      effect = "Deny"

      actions = [
        "sts:AssumeRole",
      ]

      principals {
        type = "AWS"

        identifiers = [
          "*",
        ]
      }
    }
  }

  dynamic "statement" {
    for_each = var.deployment_admin_root_delegation ? [1] : []

    content {
      sid    = "DelegateToRoot"
      effect = "Allow"

      actions = [
        "sts:AssumeRole",
      ]

      principals {
        type = "AWS"

        identifiers = [
          "arn:aws:iam::${var.aws_account_id}:root",
        ]
      }
    }
  }

  dynamic "statement" {
    for_each = var.github_actions["enabled"] ? [1] : []

    content {
      sid    = "GitHubActionsAssumeRoleWithWebIdentity"
      effect = "Allow"

      actions = [
        "sts:AssumeRoleWithWebIdentity",
      ]

      principals {
        type = "Federated"

        identifiers = [
          aws_iam_openid_connect_provider.github_actions[0].arn,
        ]
      }

      condition {
        test     = "ForAnyValue:StringLike"
        variable = "token.actions.githubusercontent.com:sub"
        values   = var.github_actions["subject_claims"]
      }

      condition {
        test     = "StringEquals"
        variable = "token.actions.githubusercontent.com:aud"

        values = [
          "sts.${var.aws_url_suffix}",
        ]
      }
    }
  }
}