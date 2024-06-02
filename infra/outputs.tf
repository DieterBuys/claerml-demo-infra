# Allocate an Elastic IP
resource "aws_eip" "clearml_server_eip" {
  vpc = true
}

# Associate the Elastic IP with the EC2 instance
resource "aws_eip_association" "clearml_server_eip_assoc" {
  instance_id   = aws_instance.clearml_server.id
  allocation_id = aws_eip.clearml_server_eip.id
}

# Output the Elastic IP address
output "clearml_server_ip" {
  value = aws_eip.clearml_server_eip.public_ip
}