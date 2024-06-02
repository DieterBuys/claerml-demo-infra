# Output the Spot Fleet Request ID
output "spot_fleet_request_id" {
  value = aws_spot_fleet_request.spot_fleet.id
}

# Output the Elastic IP address
output "clearml_server_ip" {
  value = aws_eip.clearml_server_eip.public_ip
}
