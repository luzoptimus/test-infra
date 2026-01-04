resource "aws_iam_openid_connect_provider" "github_actions" {
  count = var.github_actions["enabled"] ? 1 : 0

  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = formatlist(lower("%s"), lookup(var.github_actions, "oidc_thumbprint_list", []))

  tags = local.default_tags
}

data "aws_iam_policy_document" "github_trust_policy" {
  statement {
    effect  = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github_oidc.arn,
      ]
    }

    # TODO: Seperate NP and PR and restrict branch and environment
    # Restrict to Workflow and event type
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:bennosoft/dev-terraform:*",
        "repo:bennosoft/node-hello-world:*"
      ]
    }
  }

  statement {
    effect  = "Deny"

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github_oidc.arn,
      ]
    }

    condition {
      test     = "ForAnyValue:StringNotEquals"
      variable = "token.actions.githubusercontent.com:iss"

      values = [
        "https://token.actions.githubusercontent.com",
      ]
    }

    condition {
      test     = "ForAnyValue:StringNotEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_openid_connect_provider" "github_oidc" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    lower(var.github_oidc_thumbprint),
  ]

  tags = local.default_tags
}
