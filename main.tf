terraform {
  backend "s3" {
    bucket = "terraform-state-b87"
    key    = "github-runner/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "instances" {
  ami           = var.ami
  instance_type = "t3.small"
  vpc_security_group_ids = var.vpc_security_group_ids

  tags = {
    Name = "github-runner"
  }

}

resource "null_resource" "ansible" {

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ec2-user"
      password = "DevOps321"
      host     = aws_instance.instances.private_ip
    }

    inline = [
      "sudo dnf install python3.13-pip -y",
      "sudo pip3.11 install ansible",
      "ansible-pull -i localhost, -U https://github.com/raghudevopsb87/github-actions-runner.git runner.yml -e TOKEN=${var.TOKEN}"
    ]

  }

}

variable "TOKEN" {}
variable "ami" {
  default = "ami-0220d79f3f480ecf5"
}
variable "vpc_security_group_ids" {
  default = ["sg-09663d91a4fca31c9"]
}

