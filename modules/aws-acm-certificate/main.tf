# Find Route53 hosted zone id
data "aws_route53_zone" "this" {
  name         = "${var.domain_name_acm}."
  private_zone = var.private_zone
}

resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  key_algorithm     = "RSA_2048"

  subject_alternative_names = concat([
    var.domain_name,
    "*.${var.domain_name}"
    ],
    var.additional_acm_names
  )

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }

  # tflint-ignore: aws_resource_missing_tags
  tags = var.default_tags

  lifecycle {
    create_before_destroy = true
  }
}

# Add DNS record for ACM domain validation
resource "aws_route53_record" "this" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
    # Skips the domain if it doesn't contain a wildcard
    if length(regexall("\\*\\..+", dvo.domain_name)) > 0
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.this.zone_id
}

# Wait for validation to complete
resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn]
}
