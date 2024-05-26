provider "aws" {
  region = "us-west-2" # Change this to your preferred region
}

# Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main_vpc"
  }
}

# Create a subnet
resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2"
  tags = {
    Name = "main_subnet"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "main_igw"
  }
}

# Create a route table
resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "main_route_table"
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "main_route_table_association" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}

# Create a security group
resource "aws_security_group" "main_sg" {
  vpc_id = aws_vpc.main_vpc.id
  name   = "main_sg"

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "main_sg"
  }
}

# Create an EC2 instance
resource "aws_instance" "main_instance" {
  ami             = "ami-0327adc54a82c8d1d"
  instance_type   = "t3.xlarge"
  subnet_id       = aws_subnet.main_subnet.id
  security_groups = [aws_security_group.main_sg.name]

  tags = {
    Name = "clearml_server_instance"
  }
}

# Allocate an Elastic IP
resource "aws_eip" "clearml_server_eip" {
  instance = aws_instance.main_instance.id
  domain   = "vpc"
  tags = {
    Name = "clearml_server_eip"
  }
}
