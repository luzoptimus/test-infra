# This is a little redundant, but help to be explicit in the role's purpose
resource "aws_iam_role_policy_attachment" "lz_execution_assumerole_org_xacct" {
  role       = aws_iam_role.lz_execution.name
  policy_arn = aws_iam_policy.assumerole_org_xacct.arn
}

resource "aws_iam_role_policy_attachment" "lz_execution_administrator_access" {
  role       = aws_iam_role.lz_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
