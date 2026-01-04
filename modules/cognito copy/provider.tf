provider "aws" {
  region      = var.region
     assume_role {
     session_name = "terraform-root"  
     role_arn = format("arn:aws:iam::%s:role/cfi-prod-role-devops-terraform", var.aws_account_id)
   }
}