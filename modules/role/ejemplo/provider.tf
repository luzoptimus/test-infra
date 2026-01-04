provider "aws" {
  region      = var.region
  assume_role {
    session_name = "terraform-root"  
    role_arn = format("arn:aws:iam::%s:role/bdb-role-jenkins-terraform", var.aws_account_id)
  }
}