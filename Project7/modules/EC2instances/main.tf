resource "aws_instance" "EC2Instances" {
  ami = var.create_instance-amiid
  instance_type = var.create_instance-instancetype
  security_groups = [var.create_instance-sgname]
tags = {
  Name = var.create_instance-instance-name
}


}