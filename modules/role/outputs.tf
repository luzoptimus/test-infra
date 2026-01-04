
output "arn" {
  value       = var.role_name == null ? join("", aws_iam_role.role.*.arn) : "N/A"
  description = "Role policy ARN"
}

output "name" {
  value       = local.rolename
  description = "Role policy Name"
}

output "arn-policy" {
  value       = aws_iam_policy.policy.*.arn
  description = "Role policy Name Policy"
}

output "awtrust_arn" {
  value = var.enable && var.enabled_anywhere ? aws_rolesanywhere_trust_anchor.test[0].arn : "NA"
   description = "Role ARN anywhere trust anchor"
}