provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket         = "clearml-demo-tfstate"
    key            = "ec2-infra/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
  }
}

# SSH Key
resource "aws_key_pair" "clearml_demo_key" {
  key_name   = "clearml-demo-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINDrjaVFLkwXak/HQK+cMVvcM0nIK55dny1P7iCT9S7H"
}

# Create a VPC
resource "aws_vpc" "clearml_demo_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "clearml_demo_vpc"
  }
}

# Create a subnet
resource "aws_subnet" "clearml_demo_subnet" {
  vpc_id            = aws_vpc.clearml_demo_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "clearml_demo_subnet"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "clearml_demo_igw" {
  vpc_id = aws_vpc.clearml_demo_vpc.id
  tags = {
    Name = "clearml_demo_igw"
  }
}

# Create a route table
resource "aws_route_table" "clearml_demo_route_table" {
  vpc_id = aws_vpc.clearml_demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.clearml_demo_igw.id
  }

  tags = {
    Name = "clearml_demo_route_table"
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "clearml_demo_route_table_association" {
  subnet_id      = aws_subnet.clearml_demo_subnet.id
  route_table_id = aws_route_table.clearml_demo_route_table.id
}

# Create a security group
resource "aws_security_group" "clearml_demo_sg" {
  vpc_id = aws_vpc.clearml_demo_vpc.id
  name   = "clearml_demo_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8008
    to_port     = 8008
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "clearml_demo_sg"
  }
}

# Create an EC2 instance
resource "aws_instance" "clearml_server" {
  ami                    = "ami-0327adc54a82c8d1d"
  instance_type          = "t3.xlarge"
  subnet_id              = aws_subnet.clearml_demo_subnet.id
  vpc_security_group_ids = [aws_security_group.clearml_demo_sg.id]
  key_name               = aws_key_pair.clearml_demo_key.key_name


  root_block_device {
    volume_size = 32
    volume_type = "gp2"  # General Purpose SSD
  }


  tags = {
    Name = "clearml_server"
  }
}

# Allocate an Elastic IP
resource "aws_eip" "clearml_demo_eip" {
  instance = aws_instance.clearml_server.id
  domain   = "vpc"
  tags = {
    Name = "clearml_demo_eip"
  }
}

# Output the Elastic IP address
output "elastic_ip" {
  value = aws_eip.clearml_demo_eip.public_ip
}
