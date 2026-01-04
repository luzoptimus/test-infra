data "aws_iam_policy_document" "assumerole_org_xacct" {
  statement {
    sid    = "AllowAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "arn:aws:iam::*:role/${var.org_xacct_role_name}",
    ]
  }
}
