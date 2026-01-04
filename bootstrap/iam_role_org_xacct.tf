resource "aws_iam_role" "org_xacct" {
  name               = var.org_xacct_role_name
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.default_assumerole.json

  tags = merge(
    local.default_tags,
    {
      Name = var.org_xacct_role_name
    }
  )

  # The assumerole policy must be created with the role
  # but its content will be the responsiblity of a lambda
  # function in another component; so if it changes we don't care
  lifecycle {
    ignore_changes = [ assume_role_policy ]
  }
}

