locals {
  env = {
    account_id = "613922433778"

    api_count = 1

    vpc_cidr_digit = "1"
    test.vpc_cidr_digit = "2"

    domain_name = "dev.scoutcamp.gl26.dk"
    test.domain_name = "test.scoutcamp.gl26.dk"

    cert = "arn:aws:acm:eu-west-1:613922433778:certificate/d26bfb3f-6429-4c20-9b3d-785abd240529"
    test.cert = "arn:aws:acm:eu-west-1:613922433778:certificate/d26bfb3f-6429-4c20-9b3d-785abd240529"

    git_branch = "master"
  }

  zone_id = "ZS9MY4SIE1JCB"

  account_id = "${lookup(local.env, "${terraform.workspace}.account_id", lookup(local.env, "account_id"))}"
  vpc_cidr_digit = "${lookup(local.env, "${terraform.workspace}.vpc_cidr_digit", lookup(local.env, "vpc_cidr_digit"))}"
  api_count = "${lookup(local.env, "${terraform.workspace}.api_count", lookup(local.env, "api_count"))}"
  domain_name = "${lookup(local.env, "${terraform.workspace}.domain_name", lookup(local.env, "domain_name"))}"
  cert = "${lookup(local.env, "${terraform.workspace}.cert", lookup(local.env, "cert"))}"
  git_branch = "${lookup(local.env, "${terraform.workspace}.git_branch", lookup(local.env, "git_branch"))}"

}