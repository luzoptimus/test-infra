resource "aws_iam_role" "deployment_admin" {
  name               = "DeploymentAdmin"
  assume_role_policy = data.aws_iam_policy_document.deployment_admin_assumerole.json
  description        = "Role for Assumption of Deployment Execution roles in accounts controlled by this one"

  provisioner "local-exec" {
    command = "sleep 10"
  }
}


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


resource "aws_iam_role_policy_attachment" "deployment_admin_assumerole_deployment_execution" {
  count      = var.deployment_execution_external_id == null ? 0 : 1
  role       = aws_iam_role.deployment_admin.name
  policy_arn = aws_iam_policy.assumerole_deployment_execution[0].arn
}

resource "aws_iam_role_policy_attachment" "deployment_admin_s3_tfscaffold_rw" {
  count      = var.tfscaffold["enabled"] ? 1 : 0
  role       = aws_iam_role.deployment_admin.name
  policy_arn = aws_iam_policy.s3_tfscaffold_rw[0].arn
}

resource "aws_iam_role_policy_attachment" "deployment_admin_dynamodb_tfscaffold_rw" {
  count      = var.tfscaffold["enabled"] ? 1 : 0
  role       = aws_iam_role.deployment_admin.name
  policy_arn = aws_iam_policy.dynamodb_tfscaffold_rw[0].arn
}

resource "aws_iam_role_policy_attachment" "deployment_admin_kms_s3_tfscaffold_user" {
  count      = var.tfscaffold["enabled"] ? 1 : 0
  role       = aws_iam_role.deployment_admin.name
  policy_arn = module.kms_s3_tfscaffold[0].user_policy_arn
}

resource "aws_iam_role_policy_attachment" "deployment_admin_s3_deployment_admin_user" {
  role       = aws_iam_role.deployment_admin.name
  policy_arn = aws_iam_policy.s3_deployment_admin_rw.arn
}