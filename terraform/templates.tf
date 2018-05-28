data "template_file" "api-server-init" {
  template = "${file("templates/api-server-init.yaml")}"
  vars {
    cognito_client_id = "${aws_cognito_user_pool_client.client.id}"
    cognito_redirect_url = "https://api-${local.domain_name}/signin"
    cognito_domain = "${aws_cognito_user_pool_domain.domain.domain}.auth.${data.aws_region.current.name}.amazoncognito.com"
    cognito_pool_id = "${aws_cognito_user_pool.pool.id}"
    env = "${terraform.workspace}"
    frontend_url = "https://${data.aws_region.current.name}.amazonaws.com/${aws_s3_bucket.frontend.id}/"
  }
}