resource "aws_security_group" "sg_1" {
  name = var.sg_name


  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"

  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
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
  ami = "ami-02c7d3513f9fdf3f6"
  availability_zone = "ap-southeast-1a"
  security_groups = [aws_security_group.sg_1.name]
  instance_type = var.vm_instancetype
}