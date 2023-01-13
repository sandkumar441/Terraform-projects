resource "aws_vpc" "demo_vpc" {
  tags = {
    Name = var.vpc_name
  }
  cidr_block = var.vpc_cidr_block
}

resource "aws_internet_gateway" "demo_vpc_ig" {
  tags = {
    Name = var.vpc_ig_name
  }
  vpc_id = aws_vpc.demo_vpc.id
}

resource "aws_subnet" "sub_1" {
  tags = {
    Name = var.vpc_ig_sub1
  }
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-1a"
  vpc_id = aws_vpc.demo_vpc.id
}
resource "aws_subnet" "sub_2" {
  tags = {
    Name = var.vpc_ig_sub2
  }
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-southeast-1b"
  vpc_id = aws_vpc.demo_vpc.id
}

resource "aws_default_route_table" "vpc-route-table" {
  default_route_table_id = aws_vpc.demo_vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_vpc_ig.id
  }
  tags = {
    Name = "demo-vpc-main-RT"
  }
}
resource "aws_route_table" "vpc-route-table-private" {
  vpc_id = aws_vpc.demo_vpc.id
  tags = {
    Name = "vpc_RT_PVT"
  }
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.demo-nat-gateway.id
  }
}

resource "aws_route_table_association" "vpc-RT_PVT_association" {
  route_table_id = aws_route_table.vpc-route-table-private.id
  subnet_id = aws_subnet.sub_2.id

}
resource "aws_eip" "nat-eip" {}
resource "aws_nat_gateway" "demo-nat-gateway" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id = aws_subnet.sub_1.id
  tags = {
    Name = "demo-nat-gw"
  }
}

resource "aws_security_group" "sg_1" {
  name = var.sg_name


  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"

  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_instance" "EC2_instance" {
  tags = {
    name = "sandy_1"
  }
  ami               = "ami-02c7d3513f9fdf3f6"
  availability_zone = "ap-southeast-1a"
  security_groups   = [aws_security_group.sg_1.name]
  instance_type     = var.vm_instancetype
  subnet_id         = aws_subnet.sub_1.id
  public_ip         = ""
}
