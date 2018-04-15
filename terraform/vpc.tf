resource "aws_vpc" "vpc" {
  cidr_block = "10.${local.vpc_cidr_digit}.0.0/16"
  enable_dns_hostnames = true
  tags {
    Name = "${terraform.env}-dsg"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
}


resource "aws_subnet" "a_public" {
  cidr_block = "10.${local.vpc_cidr_digit}.1.0/24"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  map_public_ip_on_launch = false
  tags {
    Name = "a_public"
  }
}

resource "aws_subnet" "b_public" {
  cidr_block = "10.${local.vpc_cidr_digit}.2.0/24"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  map_public_ip_on_launch = false
  tags {
    Name = "b_public"
  }
}


resource "aws_subnet" "a_private" {
  cidr_block = "10.${local.vpc_cidr_digit}.3.0/24"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  map_public_ip_on_launch = false
  tags {
    Name = "a_private"
  }
}

resource "aws_subnet" "b_private" {
  cidr_block = "10.${local.vpc_cidr_digit}.4.0/24"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  map_public_ip_on_launch = false
  tags {
    Name = "b_private"
  }
}

resource "aws_subnet" "a_data" {
  cidr_block = "10.${local.vpc_cidr_digit}.5.0/24"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  map_public_ip_on_launch = false
  tags {
    Name = "a_data"
  }
}

resource "aws_subnet" "b_data" {
  cidr_block = "10.${local.vpc_cidr_digit}.6.0/24"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  map_public_ip_on_launch = false
  tags {
    Name = "b_data"
  }
}


resource "aws_eip" "a_public" {
  vpc = true
}

resource "aws_eip" "b_public" {
  vpc = true
}

resource "aws_nat_gateway" "a_public_dyn" {
  allocation_id = "${aws_eip.a_public.id}"
  subnet_id = "${aws_subnet.a_public.id}"
}

resource "aws_nat_gateway" "b_public_dyn" {
  allocation_id = "${aws_eip.b_public.id}"
  subnet_id = "${aws_subnet.b_public.id}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route_table_association" "a_public" {
  route_table_id = "${aws_route_table.public.id}"
  subnet_id = "${aws_subnet.a_public.id}"
}

resource "aws_route_table_association" "b_public" {
  route_table_id = "${aws_route_table.public.id}"
  subnet_id = "${aws_subnet.b_public.id}"
}

resource "aws_route" "public" {
  route_table_id = "${aws_route_table.public.id}"
  gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  destination_cidr_block = "0.0.0.0/0"
}

# Priavet subnets
resource "aws_route_table" "a_private" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route_table" "b_private" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route_table_association" "a_private" {
  route_table_id = "${aws_route_table.a_private.id}"
  subnet_id = "${aws_subnet.a_private.id}"
}

resource "aws_route_table_association" "b_private" {
  route_table_id = "${aws_route_table.b_private.id}"
  subnet_id = "${aws_subnet.b_private.id}"
}

resource "aws_route" "a_private_dyn" {
  route_table_id = "${aws_route_table.a_private.id}"
  nat_gateway_id = "${aws_nat_gateway.a_public_dyn.id}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "b_private_dyn" {
  route_table_id = "${aws_route_table.b_private.id}"
  nat_gateway_id = "${aws_nat_gateway.b_public_dyn.id}"
  destination_cidr_block = "0.0.0.0/0"
}