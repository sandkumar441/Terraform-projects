provider "aws"{

}
data "aws_availability_zones" "all-azs"{}



resource "aws_instance" "vms" {
  tags = {
    Name = "vm-${count.index+1}"
  }
count = length(data.aws_availability_zones.all-azs.names)
  availability_zone = data.aws_availability_zones.all-azs.names[count.index]
  ami = lookup(var.ami-id, var.region-name )
  instance_type = "t2.micro"


}

resource "aws_vpc" "vpc_s" {
  tags = {
    Name = "VPC"
  }
cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subs" {
  vpc_id = aws_vpc.vpc_s.id
  count = length(data.aws_availability_zones.all-azs.names)
  tags = {
    Name = "sub-${count.index+1}"
  }
  availability_zone = data.aws_availability_zones.all-azs.names[count.index]
  cidr_block = "10.0.${count.index+1}.0/24"
}