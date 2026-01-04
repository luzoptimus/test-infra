 #ejemplo para adicionar politica al role existente
module "sso_role" {
  source                  = "../"
  region                  = var.region
  namespace               = var.namespace
  environment             = var.environment
  project                 = var.project
  role_name               = "bdb-role-jenkins-terraform"
  aws_iam_policy_document = [data.template_file.containerTaskJson.rendered]
  type                    = "sso"
  tags                    = var.tags
  aws_account_id          = var.aws_account_id
  }


locals {
  lista_accounts = concat([
    for i in var.accountIds : 
      format("arn:aws:sso:::account/%s", i) ],
 ["arn:aws:sso:::permissionSet/*/**"], ["arn:aws:sso:::instance/*"])
}
data "template_file" "containerTaskJson" {
  template = "${file("./sso.json")}"

  vars = {
    accountIds = jsonencode(concat(local.lista_accounts))
  }
}
