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
data "aws_availability_zones" "all-azs"{}
resource "aws_instance" "vms" {
  tags = {
    Name = "vm-${count.index+1}"
  }
  count = length(data.aws_availability_zones.all-azs.names)
  availability_zone = data.aws_availability_zones.all-azs.names[count.index]
  ami = lookup(var.ami-id,var.region-name)
  instance_type = var.size-of-vm
  user_data = <<EOF
#!/bin/bash
yum update -y
yum install -y httpd
service httpd start
chkconfig httpd on
echo "<body bgcolor="#FFFF00"></body>" > /var/www/html/index.html
EOF
}

resource "aws_lb" "demo-lb" {
  name = "load-balancer"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.sg_1.id]

}

resource "aws_lb_target_group" "my-tg" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc_s.id
}
resource "aws_lb_target_group_attachment" "tg-attachment" {
  count = length(data.aws_availability_zones.all-azs.names)
  target_group_arn = aws_lb_target_group.my-tg.arn
  target_id = aws_instance.vms[count.index].id
}
resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.demo-lb.arn
  port = "80"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.my-tg.arn
  }
}

