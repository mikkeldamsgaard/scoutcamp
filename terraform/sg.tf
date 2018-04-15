resource "aws_security_group" "api-alb" {
  description = "Security group for the api alb"
  tags { Name = "api" }
  vpc_id = "${aws_vpc.vpc.id}"
  ingress {
    from_port = 4567
    protocol = "TCP"
    to_port = 4567
    cidr_blocks = ["0.0.0.0/0"]
    description = "http"
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "api-server" {
  description = "Security group for the app servers"
  tags { Name = "appserver" }
  vpc_id = "${aws_vpc.vpc.id}"
  ingress {
    from_port = 8000
    protocol = "TCP"
    to_port = 8000
    security_groups = ["${aws_security_group.api-alb.id}"]
    description = "alb"
  }
  ingress {
    from_port = 22
    protocol = "TCP"
    to_port = 22
    cidr_blocks = ["${aws_vpc.vpc.cidr_block}"]
    description = "vpc"
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bastion_security_group" {
  name = "${terraform.env}-bastion"
  description = "Security group for the bastion host"
  vpc_id = "${aws_vpc.vpc.id}"
  ingress {
    from_port = 22
    protocol = "TCP"
    to_port = 22
    cidr_blocks = ["80.198.90.226/32", "188.114.186.102/32"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}