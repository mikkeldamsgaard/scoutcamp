resource "aws_instance" "bastion" {
  ami = "ami-785db401"
  instance_type = "t2.micro"
  key_name = "scoutcamp"
  subnet_id = "${aws_subnet.a_public.id}"
  vpc_security_group_ids = ["${aws_security_group.bastion_security_group.id}"]
  associate_public_ip_address = true
  tags {
    Name = "${terraform.env}-bastion"
  }
}

output "bastion.ip" {
  value = "${aws_instance.bastion.public_ip}"
}

