resource "aws_cognito_user_pool" "pool" {
  lifecycle {
    # These two attributes in ignore changes are just terraform quirks.
    ignore_changes = ["schema"]
  }
  name = "${terraform.workspace}"

  password_policy {
    require_lowercase = true
    minimum_length = 8
    require_numbers = true
    require_uppercase = true
    require_symbols = false
  }

  username_attributes = ["email"]

  verification_message_template {
    default_email_option = "CONFIRM_WITH_LINK"
  }

  schema {
    attribute_data_type = "String"
    name = "email"
    required = true
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

  schema {
    attribute_data_type = "String"
    name = "name"
    required = true
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }


  auto_verified_attributes = ["email"]

  provisioner "local-exec" {
    command = <<EOF
tmp=`mktemp`
cat > $tmp <<EOBS
source bin/awsudo.sh arn:aws:iam::${local.account_id}:role/cloudpartners-iam
aws cognito-idp create-identity-provider --user-pool-id ${aws_cognito_user_pool.pool.id} --provider-name Google --provider-type Google --region eu-west-1 --provider-details "{\"authorize_scopes\":\"email openid profile\",\"client_id\":\"154496312926-ok18154nn0qiotsdmij04uokl90glk7m.apps.googleusercontent.com\",\"client_secret\":\"R2bwh00hJQfudfJvwJWTuZ8R\"}" --attribute-mapping "{\"username\":\"sub\",\"email\":\"email\",\"name\":\"name\"}"
EOBS
bash $tmp
rm $tmp
EOF
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name = "scoutcamp"
  user_pool_id = "${aws_cognito_user_pool.pool.id}"
  callback_urls = ["https://api-${local.domain_name}/signin"]
  logout_urls = ["https://api-${local.domain_name}/signout"]
  supported_identity_providers = ["COGNITO", "Google"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = ["code", "implicit"]
  allowed_oauth_scopes = ["email","openid"]
}

resource "aws_cognito_user_pool_domain" "domain" {
  domain = "scoutcamp-${terraform.workspace}"
  user_pool_id = "${aws_cognito_user_pool.pool.id}"
}

