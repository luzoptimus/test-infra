resource "aws_rolesanywhere_profile" "test" {
  count      =  var.enable && var.enabled_anywhere ? 1 : 0

  name      = format("%s-%s-roleAny-%s-%s", var.namespace, var.environment, var.project, var.type)
  role_arns = [aws_iam_role.role[0].arn]
  enabled   = true
  tags      = merge({ "Name" = format("%s-%s-roleAny-%s-%s", var.namespace, var.environment, var.project, var.type)}, {"Project" = var.project}, var.tags)
}

resource "aws_rolesanywhere_trust_anchor" "test" {
  count =  var.enable && var.enabled_anywhere ? 1 : 0
  name = format("%s-%s-roleAnyCA-%s-%s", var.namespace, var.environment, var.project, var.type)
  enabled   = true
  source {
    source_data {
      acm_pca_arn = var.acm_pca_arn
      x509_certificate_data = tls_self_signed_cert.ca[0].cert_pem
    }
    source_type = var.source_type
  }
 tags   = merge({ "Name" = format("%s-%s-roleAnyCA-%s-%s", var.namespace, var.environment, var.project, var.type)}, {"Project" = var.project}, var.tags)
}

# resource "aws_secretsmanager_secret" "tls" {
#   count = var.enable && var.enabled_anywhere ? 1 : 0
#   name                    = format("%s-%s-sm-%s-%s_ca", var.namespace, var.environment, var.project, random_id.secret[0].hex) 
#   description             = "contains TLS certs and private keys"
#   kms_key_id              = var.kms_key_id
#   recovery_window_in_days = var.recovery_window
#   tags                    = var.tags
# }

resource "random_id" "secret" {
  count = var.enable && var.enabled_anywhere ? 1 : 0
  keepers = {
    # Generate a new id each time we switch to a new rolesanywhereca_id
    rolesanywhereca_id = aws_rolesanywhere_trust_anchor.test[0].id
  }

  byte_length = 4
}

# resource "aws_secretsmanager_secret_version" "tls" {
#   count = var.enable && var.enabled_anywhere ? 1 : 0
#   secret_id     = aws_secretsmanager_secret.tls[0].id
#   secret_string = local.secret
# }


locals {
  tls_data = {
    vault_ca   = var.enable && var.enabled_anywhere ? base64encode(tls_self_signed_cert.ca[0].cert_pem) :"NA"
    #vault_cert = var.enable && var.enabled_anywhere ? base64encode(tls_locally_signed_cert.server[0].cert_pem) :"NA"
    vault_pk   = var.enable && var.enabled_anywhere ? base64encode(tls_private_key.ca[0].private_key_pem) :"NA"
    }
}

locals {
  secret = jsonencode(local.tls_data)
}


# Generate a private key so you can create a CA cert with it.
resource "tls_private_key" "ca" {
  count = var.enable && var.enabled_anywhere ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
  provisioner "local-exec" {
     command = "echo '${tls_private_key.ca[0].private_key_pem}' > ./vault-ca-key.pem"
   }
}

/* resource "tls_cert_request" "example" {
   count = var.enable && var.enabled_anywhere ? 1 : 0
  private_key_pem = tls_private_key.ca[0].private_key_pem

  subject {
    common_name = "vault.optimus.io"
    organization = "Custom CA"
    organizational_unit = "Optimus"
  }
} */

# Create a CA cert with the private key you just generated.
resource "tls_self_signed_cert" "ca" {
  count = var.enable && var.enabled_anywhere ? 1 : 0
  #key_algorithm   = tls_private_key.ca.algorithm
  private_key_pem = tls_private_key.ca[0].private_key_pem

  subject {
    common_name = "vault.optimus.io"
    organization = "Custom CA"
    organizational_unit = "Optimus"
  }

  validity_period_hours = 87659

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]

  is_ca_certificate = true

   provisioner "local-exec" {
     command = "echo '${tls_self_signed_cert.ca[0].cert_pem}' > ./vault-ca.pem"
   }
}


# resource "tls_locally_signed_cert" "server" {
#   count = var.enable && var.enabled_anywhere ? 1 : 0
#   cert_request_pem   = tls_cert_request.example[0].cert_request_pem
#   #ca_key_algorithm   = tls_private_key.ca.algorithm
#   ca_private_key_pem = tls_private_key.ca[0].private_key_pem
#   ca_cert_pem        = tls_self_signed_cert.ca[0].cert_pem

#   validity_period_hours = 3652 # 30 days

#   allowed_uses = [
#     "client_auth",
#     "digital_signature",
#     "key_agreement",
#     "key_encipherment",
#     "server_auth",
#   ]

# }

