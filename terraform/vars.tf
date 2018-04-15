locals {
  env = {
    account_id = "613922433778"
    vpc_cidr_digit = "1"
    api_count = 1
  }

  account_id = "${lookup(local.env, "${terraform.workspace}.account_id", lookup(local.env, "account_id"))}"
  vpc_cidr_digit = "${lookup(local.env, "${terraform.workspace}.vpc_cidr_digit", lookup(local.env, "vpc_cidr_digit")}"
  api_count = "${lookup(local.env, "${terraform.workspace}.api_count", lookup(local.env, "api_count"))}"

}