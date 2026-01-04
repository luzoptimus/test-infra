output "cf_id" {
  value       =  var.enable_s3 ? aws_cloudfront_distribution.default[0].id : var.enabled ? aws_cloudfront_distribution.cdn[0].id : ""
  description = "ID of AWS CloudFront distribution"
}

output "cf_arn" {
  value       =  var.enable_s3 ? aws_cloudfront_distribution.default[0].arn : var.enabled ? aws_cloudfront_distribution.cdn[0].arn : ""
  description = "ARN of AWS CloudFront distribution"
}

output "cf_status" {
  value       =  var.enable_s3 ? aws_cloudfront_distribution.default[0].status : var.enabled ? aws_cloudfront_distribution.cdn[0].status : ""
  description = "Current status of the distribution"
}

output "cf_domain_name" {
  value       =  var.enable_s3 ? aws_cloudfront_distribution.default[0].domain_name : var.enabled ? aws_cloudfront_distribution.cdn[0].domain_name : ""
  description = "Domain name corresponding to the distribution"
}

output "cf_etag" {
  value       =  var.enable_s3 ? aws_cloudfront_distribution.default[0].etag : var.enabled ? aws_cloudfront_distribution.cdn[0].etag : ""
  description = "Current version of the distribution's information"
}

output "cf_hosted_zone_id" {
  value       =  var.enable_s3 ? aws_cloudfront_distribution.default[0].hosted_zone_id : var.enabled ? aws_cloudfront_distribution.cdn[0].hosted_zone_id : ""
  description = "CloudFront Route 53 zone ID"
}

output "aliases" {
  value       = var.aliases
  description = "Aliases of the CloudFront distibution"
}
##salida cloudfront functions
output "arn_function" {
  value       = join("", aws_cloudfront_function.function.*.arn)
  description = "Muestra el status de la funcion"
}

output "status_function" {
  value       = join("", aws_cloudfront_function.function.*.status)
  description = "Muestra el status de la funcion"
}
