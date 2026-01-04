##
# Variables Global to All Component Deployments for the PR Landing Zone
##

tfscaffold_bucket_prefix = "tfscaffold"
project = "optimus"
group   = "dev"

# The AWS Account ID explicitly of the Organizations Primary Account
aws_account_id = "273354644813"

# Once you've deployed Landing Zone, this cannot and must not be changed. Ever.
org_xacct_role_name = "OrgPrimaryCrossAccount"

# Route53
root_domain_enable     = false
root_domain_enable_ses = false
root_domain_name       = ""

primary_cloudwatch_audit_firehose_enable  = true
audit_cloudwatch_audit_firehose_enable    = true
security_cloudwatch_audit_firehose_enable = true
shared_cloudwatch_audit_firehose_enable   = true
avm_cloudwatch_audit_firehose_enable      = true

domain_name_acm = "dev.healthcare.optimusbrand.io"
private_zone = false

