output "public_ip" {
  value = aws_instance.app.public_ip
}

output "public_dns" {
  value = aws_instance.app.public_dns
}

output "ecr_repository_url" {
  value = aws_ecr_repository.task_manager.repository_url
}