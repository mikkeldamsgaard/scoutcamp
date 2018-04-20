resource "aws_route53_record" "bastion" {
  depends_on = ["aws_instance.bastion"]
  zone_id = "${local.zone_id}"
  name    = "bastion.${local.domain_name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.bastion.public_ip}"]
}

resource "aws_route53_record" "api" {
  zone_id = "${local.zone_id}"
  name = "api-${local.domain_name}"
  type = "CNAME"
  ttl     = "300"
  records = ["${aws_alb.api.dns_name}"]
}

//resource "aws_route53_record" "s3" {
//  name = "${local.domain_name}"
//  type = "CNAME"
//  zone_id = "${local.zone_id}"
//  records = ["${}"]
//}