provider "aws" {
  assume_role {
    external_id = "terraform"
    session_name = "terraform"
    role_arn = "arn:aws:iam::${local.account_id}:role/cloudpartners-iam"
  }
  region = "eu-west-1"
}
