provider "aws" {
  region  = var.region

  assume_role {
    role_arn     = "arn:aws:iam::${var.aws_account_id}:role/${var.org_xacct_role_name}"
    session_name = "terraform"
    external_id  = var.org_xacct_external_id
  }

  allowed_account_ids = [
    var.aws_account_id,
  ]
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  assume_role {
    role_arn     = "arn:aws:iam::${var.aws_account_id}:role/${var.org_xacct_role_name}"
    session_name = "terraform"
    external_id  = var.org_xacct_external_id
  }

  # For no reason other than redundant safety
  # we only allow the use of the AWS Account
  # specified in the environment variables.
  # This helps to prevent accidents.
  allowed_account_ids = [
    var.aws_account_id
  ]
}