output "clearml_server_ip" {
  value = aws_eip.clearml_server_eip.public_ip
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.clearml_cluster.name
}