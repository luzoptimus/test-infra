resource "aws_iam_role" "lz_execution" {
  name               = var.lz_execution_role_name
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.default_assumerole.json

  tags = merge(
    local.default_tags,
    {
      Name = var.lz_execution_role_name
    }
  )
}

