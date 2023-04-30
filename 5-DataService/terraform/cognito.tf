resource "aws_cognito_user_pool_domain" "main" {
  domain          = format("auth.%s", var.hosted_zone_name) // e.g. auth.example.org
  certificate_arn = aws_acm_certificate.cert.arn
  user_pool_id    = aws_cognito_user_pool.this.id
}

resource "aws_cognito_user_pool" "this" {
  name                     = var.user_pool_name
  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]

  user_attribute_update_settings {
    # A list of attributes requiring verification before update. If set, the provided value(s) must also be set in auto_verified_attributes
    attributes_require_verification_before_update = ["email"]
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  email_configuration {
    # default email functionality built into Cognito
    email_sending_account = "COGNITO_DEFAULT"
  }
}

# TODO
resource "aws_cognito_resource_server" "resource" {
  identifier = format("https://%s", aws_cognito_user_pool_domain.main.domain)
  name       = format("%s - Resource Server", var.project_name)

  # Associate your custom scopes with an app client, 
  # and your app can request those scopes in OAuth2.0 authorization code grants, implicit grants, and client credentials grants
  scope {
    scope_name        = "notice:read"
    scope_description = "Read a notice"
  }

  scope {
    scope_name        = "notice:write"
    scope_description = "Create, Update or Delete a notice"
  }

  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_pool_client" "this" {
  name = format("%s - Client", var.project_name)

  user_pool_id                         = aws_cognito_user_pool.this.id
  callback_urls                        = [format("https://%s", var.hosted_zone_name)]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  supported_identity_providers         = ["COGNITO"]
}