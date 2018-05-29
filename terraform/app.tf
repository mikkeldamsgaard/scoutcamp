resource "aws_alb" "api" {
  name_prefix = "${terraform.workspace}"
  subnets = ["${aws_subnet.a_public.id}", "${aws_subnet.b_public.id}"]
  security_groups = ["${aws_security_group.api-alb.id}"]
}

resource "aws_alb_target_group" "api" {
  name_prefix = "${terraform.workspace}"
  port = 4567
  protocol = "HTTP"
  vpc_id = "${aws_vpc.vpc.id}"
  health_check {
    path = "/isLoggedIn"
  }
}

resource "aws_alb_listener" "api" {
  "default_action" {
    target_group_arn = "${aws_alb_target_group.api.arn}"
    type = "forward"
  }
  load_balancer_arn = "${aws_alb.api.arn}"
  port = 4567
}

resource "aws_alb_listener" "api-https" {
  "default_action" {
    target_group_arn = "${aws_alb_target_group.api.arn}"
    type = "forward"
  }
  load_balancer_arn = "${aws_alb.api.arn}"
  protocol = "HTTPS"
  port = 443
  certificate_arn = "${local.cert}"
}

resource "aws_autoscaling_group" "api" {
  name_prefix = "${terraform.workspace}-api-${aws_launch_configuration.api.name}"
  launch_configuration = "${aws_launch_configuration.api.id}"
  max_size = "${local.api_count}"
  min_size = "${local.api_count}"
  vpc_zone_identifier = ["${aws_subnet.a_private.id}","${aws_subnet.b_private.id}"]
  availability_zones = ["${data.aws_availability_zones.available.names}"]
  tag {
    key = "Name"
    propagate_at_launch = true
    value = "${terraform.workspace}-scoutcamp-api"
  }
  target_group_arns = ["${aws_alb_target_group.api.id}"]
  lifecycle { create_before_destroy = true }
}

resource "aws_launch_configuration" "api" {
  name_prefix = "${terraform.workspace}-api"
  image_id = "ami-7a187c03"
  iam_instance_profile = "${aws_iam_instance_profile.api.name}"
  instance_type = "t2.micro"
  key_name = "scoutcamp"
  root_block_device {
    volume_size = 10
  }
  security_groups = ["${aws_security_group.api-server.id}"]
  user_data = "${data.template_file.api-server-init.rendered}"
  lifecycle { create_before_destroy = true }
}

resource "aws_iam_instance_profile" "api" {
  name_prefix = "${terraform.workspace}-api"
  role = "${aws_iam_role.api.id}"
}

resource "aws_iam_role" "api" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": [
        "ec2.amazonaws.com"
      ]
    },
    "Action": [
      "sts:AssumeRole"
    ]
  }]
}
EOF
}

resource "aws_iam_role_policy" "api_s3_read_only_policy" {
  name = "s3-read-only-policy"
  role = "${aws_iam_role.api.id}"
  policy = <<EOF
{
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "s3:Get*",
      "s3:List*"
    ],
    "Resource": "*"
  }]
}
EOF
}

output "lb" {
  value = "${aws_alb.api.dns_name}"
}