packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

variable "aws_access_key" {
  type    = string
  default = ""
}

variable "aws_secret_key" {
  type    = string
  default = ""
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "source_ami" {
  type    = string
  default = "ami-027492973b111510a"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ssh_username" {
  type    = string
  default = "ec2-user"
}

variable "ami_name" {
  type    = string
  default = "clearml-agent"
}

source "amazon-ebs" "clearml_ami" {
  access_key                  = var.aws_access_key
  secret_key                  = var.aws_secret_key
  region                      = var.region
  source_ami                  = var.source_ami
  instance_type               = var.instance_type
  ssh_username                = var.ssh_username
  ami_name                    = "${var.ami_name}-${timestamp()}"
  associate_public_ip_address = true
}

build {
  sources = ["source.amazon-ebs.clearml_ami"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y python3",
      "sudo pip3 install clearml-agent"
    ]
  }
}