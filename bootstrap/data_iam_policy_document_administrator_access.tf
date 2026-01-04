data "aws_iam_policy_document" "administrator_access" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    not_actions = [
      "organizations:CloseAccount",
      "organizations:RemoveAccountFromOrganization",
    ]

    resources = [
      "*",
    ]
  }
}
