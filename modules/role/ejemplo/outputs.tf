
# output "arn" {
#   value       = var.role_name == null ? join("", aws_iam_role.role.*.arn) : "N/A"
#   description = "Role policy ARN"
# }

# output "name" {
#   value       = local.rolename
#   description = "Role policy Name"
# }

# output "arn-policy" {
#   value       = module.ecr_role.arn-policy
#   description = "Role policy Name Policy"
# }