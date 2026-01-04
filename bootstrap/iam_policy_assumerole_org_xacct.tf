resource "aws_iam_policy" "assumerole_org_xacct" {
  name   = "AssumeRoleOrgXacct"
  path   = "/"
  policy = data.aws_iam_policy_document.assumerole_org_xacct.json

  tags = merge(
    local.default_tags,
    {
      Name = "AssumeRoleOrgXacct"
    }
  )
}

