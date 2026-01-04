resource "aws_iam_role" "deployment_execution" {
  provider = aws.self

  count = alltrue([
    length(local.trusted_aws_account_ids) > 0,
    contains(keys(var.avm_tooling), "deployment_execution_external_id"),
    var.avm_tooling["deployment_execution_external_id"] != null,
    var.avm_tooling["deployment_execution_external_id"] != "",
  ]) ? 1 : 0

  name               = "DeploymentExecution"
  assume_role_policy = data.aws_iam_policy_document.tooling_deployment_admin_assumerole[0].json
  description        = "Role for Deployment Execution as assumed from a Tooling Account Deployment Admin role"

  provisioner "local-exec" {
    command = "sleep 10"
  }

  depends_on = [
    module.bs_tool[0].deployment_admin_role_arn,
  ]
}

data "aws_iam_policy_document" "tooling_deployment_admin_assumerole" {
  count = alltrue([
    length(local.trusted_aws_account_ids) > 0,
    contains(keys(var.avm_tooling), "deployment_execution_external_id"),
    var.avm_tooling["deployment_execution_external_id"] != null,
    var.avm_tooling["deployment_execution_external_id"] != "",
  ]) ? 1 : 0

  statement {
    sid    = "DeploymentAdminAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "AWS"

      identifiers = coalesce(distinct(formatlist(
        "arn:aws:iam::%s:role/DeploymentAdmin",
        local.trusted_aws_account_ids,
      )))
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"

      values = [
        "*/${local.lz.organization_ous["tl"].id}/*",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"

      values = [
        var.avm_tooling["deployment_execution_external_id"],
      ]
    }
  }

  depends_on = [
    module.bs_tool[0].deployment_admin_iam_role_arn,
  ]
}
