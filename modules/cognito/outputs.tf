output "user_pool" {
  description = "The full `aws_cognito_user_pool` object."
  value       = aws_cognito_user_pool.user_pool[0].id
}

output "client_ids" {
  description = "Map of client IDs for all user pool clients"
  value = {
    for key, client in aws_cognito_user_pool_client.client : 
    key => client.id
  }
}

output "client_secrets" {
  description = "Map of client secrets for all user pool clients"
  value = {
    for key, client in aws_cognito_user_pool_client.client : 
    key => client.client_secret
  }
  sensitive = true
}
output "arn" {
  description = "The full `aws_cognito_user_pool` object."
  value       = join("",aws_cognito_user_pool.user_pool.*.arn)
}

output "id" {
  description = "The full `aws_cognito_user_pool` object."
  value       = join("",aws_cognito_user_pool.user_pool.*.id)
}

