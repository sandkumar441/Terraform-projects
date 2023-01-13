packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "first-packer-ami"
  instance_type = "t2.micro"
  region        = "ap-southeast-1"
  source_ami = "ami-029562ad87fe1185c"
  ssh_username = "ubuntu"
}
build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "shell" {
    inline = [
      "echo Installing Redis",
      "sleep 30",
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo service nginx restart"
    ]
  }
}
