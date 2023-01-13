resource "aws_iam_group" "my_iam_group" {
  name = "Iam_Users"

}

resource "aws_iam_user" "my_iam_user" {
  name = "Iam_User_1"
}

resource "aws_ebs_volume" "my_first_ebs_volume" {
  availability_zone = "ap-southeast-1a"
  size = 20
}

output "my-iam-details" {
  value = aws_iam_user.my_iam_user.name
}


resource "aws_instance" "ec2-instances" {
  tags = {
    Name = "Sandy-2"
  }
  ami = "ami-02c7d3513f9fdf3f6"
  availability_zone = "ap-southeast-1a"
  instance_type = var.vm_instancetype
  user_data = <<EOF
#!/bin/bash
yum update -y
yum install -y httpd
service httpd start
chkconfig httpd on
echo "<body bgcolor="#FFFF00"></body>" > /var/www/html/index.html
EOF
}


resource "aws_iam_group_membership" "mem" {
  group = aws_iam_group.my_iam_group.name
  name  = "mem1"
  users = [aws_iam_user.my_iam_user.name]
}

resource "aws_ebs_volume" "ebs-volume-1" {
  availability_zone = "ap-southeast-1a"
  size = 10
}

resource "aws_volume_attachment" "ebs-ec2-volume-attachment" {
  device_name = "/dev/sdh"
  instance_id = aws_instance.ec2-instances.id
  volume_id   = aws_ebs_volume.ebs-volume-1.id
}
resource "aws_ami_from_instance" "instance-2-ami" {
  name               = "ami-from-instance"
  source_instance_id = aws_instance.ec2-instances.id
}

resource "aws_launch_template" "ami-template" {
  name_prefix   = "amitemp"
  image_id      = aws_instance.ec2-instances.ami
  instance_type = var.vm_instancetype
}
data "aws_availability_zones" "all-azs" {}
resource "aws_autoscaling_group" "bar" {
  availability_zones = data.aws_availability_zones.all-azs.names
  max_size           = 5
  min_size           = 3

  launch_template {
    id      = aws_launch_template.ami-template.id
    version = "$Latest"
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

resource "aws_vpc" "default-vpc" {
tags = {
  Name = "demo-VPC"
}
  cidr_block = "10.0.0.0/16"
}
resource "aws_lb" "demo-lb" {
  name               = "load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_1.id]


}

resource "aws_subnet" "subs" {
  vpc_id = aws_vpc.default-vpc.id
  count = length(data.aws_availability_zones.all-azs.names)
  tags = {
    Name = "sub-${count.index+1}"
  }
  availability_zone = data.aws_availability_zones.all-azs.names[count.index]
  cidr_block = "10.0.${count.index+1}.0/24"
}


