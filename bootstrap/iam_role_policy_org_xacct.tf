resource "aws_iam_role_policy" "org_xacct_administrator_access" {
  name   = "AdministratorAccess"
  role   = aws_iam_role.org_xacct.id
  policy = data.aws_iam_policy_document.administrator_access.json
}
