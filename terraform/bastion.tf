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

resource "aws_instance" "disk" {
  ami = "ami-f90a4880"
  instance_type = "c5.2xlarge"
  key_name = "scoutcamp"
  subnet_id = "${aws_subnet.b_private.id}"
  vpc_security_group_ids = ["${aws_security_group.api-server.id}"]
  #associate_public_ip_address = true
  tags {
    Name = "${terraform.env}-disk"
  }
}

output "disk.ip" {
  value = "${aws_instance.disk.private_ip}"
}


//resource "aws_instance" "disk2" {
//  ami = "ami-f90a4880"
//  instance_type = "r4.16xlarge"
//  key_name = "scoutcamp"
//  subnet_id = "${aws_subnet.a_private.id}"
//  vpc_security_group_ids = ["${aws_security_group.api-server.id}"]
//  ebs_optimized = true
//  #associate_public_ip_address = true
//  tags {
//    Name = "${terraform.env}-disk2"
//  }
//  ebs_block_device {
//    device_name = "/dev/sda2"
//    volume_size = 1000
//  }
//}
//
//output "disk2.ip" {
//  value = "${aws_instance.disk2.private_ip}"
//}




