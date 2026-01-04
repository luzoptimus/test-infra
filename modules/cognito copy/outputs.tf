output "user_pool" {
  description = "The full `aws_cognito_user_pool` object."
  value       = resource.aws_cognito_user_pool.user_pool
}

output "client_id" {
  description = "The full `aws_cognito_user_pool_client` object."
  value       = resource.aws_cognito_user_pool_client.client
}

output "arn" {
  description = "The full `aws_cognito_user_pool` object."
  value       = join("",resource.aws_cognito_user_pool.user_pool.*.arn)
}

output "id" {
  description = "The full `aws_cognito_user_pool` object."
  value       = join("",resource.aws_cognito_user_pool.user_pool.*.id)
}

