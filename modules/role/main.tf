
resource "aws_iam_role" "role" {
  count              = var.role_name == null && var.enable ? 1 : 0
  name               = format("%s-%s-role-%s-%s", var.namespace, var.environment, var.project, var.type)
  description        = format("Role %s enviroment %s project %s",var.type, var.environment, var.project)
  assume_role_policy = var.assume_role_policy
  tags               = merge({ "Name" = format("%s-%s-role-%s-%s", var.namespace, var.environment, var.project, var.type )}, {"Project" = var.project}, var.tags)
}

resource "aws_iam_policy" "policy" {
  count       = var.aws_iam_policy_document  != [] &&  var.enable ? length(var.aws_iam_policy_document) : 0
  name        = format("%s-%s-poli-%s-%s-%s", var.namespace, var.environment, var.project, var.type, count.index)
  description = format("Policy %s enviroment %s project %s %s",var.type, var.environment, var.project, count.index)
  policy      = element(var.aws_iam_policy_document, count.index)
}

resource "aws_iam_role_policy_attachment" "role" {
  count      = var.aws_iam_policy_document  != [] && var.enable ? length(var.aws_iam_policy_document) : 0
  role       = local.rolename
  policy_arn = element(aws_iam_policy.policy.*.arn, count.index)
}

resource "aws_iam_role_policy_attachment" "policy_arn" {
  count      = var.enable ? length(var.policy_arn) : 0 
  role       = local.rolename
  policy_arn = element(var.policy_arn, count.index)
}


locals {
  rolename        = var.role_name == null ? join("", aws_iam_role.role.*.name) : var.role_name
}