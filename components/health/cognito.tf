module "cognito_user_pool" {
  source = "../../modules/cognito"

  name                        = var.subproject
  region                      = var.region
  aws_account_id              = var.aws_account_id
  environment                 = var.environment
  project                     = var.project
  subproject                  = var.subproject
  username_attributes         = var.username_attributes
  auto_verified_attributes    = var.auto_verified_attributes
  account_recovery_mechanisms = var.account_recovery_mechanisms
  # If invited by an admin
  invite_email_subject                        = var.invite_email_subject
  domain                                      = var.domain
  schema_attributes                           = var.schema_attributes
  default_client_supported_identity_providers = var.default_client_supported_identity_providers
  clients = [
    {
      name                                         = format("%s-app-%s", var.environment, var.project)
      read_attributes                              = ["email", "custom:user_id", "custom:full_name", "address", "birthdate", "email_verified", "family_name", "gender", "given_name", "locale", "middle_name", "name", "nickname", "phone_number", "phone_number_verified", "picture", "preferred_username", "profile", "updated_at", "website", "zoneinfo" ]
      write_attributes                             = ["email", "custom:user_id", "custom:full_name", "address", "birthdate", "family_name", "gender", "given_name", "locale", "middle_name", "name", "nickname", "phone_number", "picture", "preferred_username", "profile", "updated_at", "website", "zoneinfo" ]
      allowed_oauth_scopes                         = ["email", "openid", "aws.cognito.signin.user.admin"]
      allowed_oauth_flows                          = ["code", "implicit"]
      allowed_oauth_flows_user_pool_client         = true
      default_client_prevent_user_existence_errors = "ENABLED"
      explicit_auth_flows                          = ["ALLOW_ADMIN_USER_PASSWORD_AUTH", "ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_USER_PASSWORD_AUTH"]
      callback_urls                                = ["https://${var.domain_name}/"]
      generate_secret                              = var.generate_secret
    }
  ]
  #Access token expiration
  access_token_validity = var.access_token_validity
  id_token_validity     = var.id_token_validity
  user_device_tracking  = var.user_device_tracking
  tags                  = local.tags
  enable_cw_logs        = false
  #lambda_kms_key_id     = var.kms_cloudhsm == "" ? module.kms_key.key_arn : var.kms_cloudhsm
  #lambda_arn_email      = module.lambda_email_cognito.lambda_arn
  #lambda_version_email  = var.lambda_version_email
  ## post_authentication
  #lambda_post_authentication       = module.lambda_email_activation.lambda_arn
  #custom_css                       = ".banner-customizable {padding: 25px 0px 25px 0px; background-color: #F4F6F6;}"
  #image_file                       = "image.jpg"
  groups                           = var.groups
  email                            = var.user_email
  user_name                        = var.user_name
  password                         = "Test.1234"
  temporary_password_validity_days = 7
  attributes_user                  = var.attributes_user

  identity_providers = [
    {
      provider_name = "Google"
      provider_type = "Google"

      provider_details = {
        authorize_scopes              = "profile email openid"
        client_id                     = var.client_id_google    # This should be retrieved from AWS Secret Manager, otherwise Terraform will force an in-place replacement because it is treated as a sensitive value
        client_secret                 = var.client_secret_google # This should be retrieved from AWS Secret Manager, otherwise Terraform will force an in-place replacement because it is treated as a sensitive value
        attributes_url_add_attributes = "true"
        authorize_url                 = "https://accounts.google.com/o/oauth2/v2/auth"
        oidc_issuer                   = "https://accounts.google.com"
        token_request_method          = "POST"
        token_url                     = "https://www.googleapis.com/oauth2/v4/token"
      }

      attribute_mapping = {
        email    = "email"
        username = "sub"
      }
    }
  ]
}
