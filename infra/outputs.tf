output "clearml_server_ip" {
  value = aws_eip.clearml_server_eip.public_ip
}