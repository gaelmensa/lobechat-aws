output "ec2_public_ip" {
  description = "Elastic IP of the EC2 instance"
  value       = aws_eip.lobechat.public_ip
}

output "lobechat_url" {
  description = "Public LobeChat URL (sslip.io resolves to the EIP)"
  value       = "https://${replace(aws_eip.lobechat.public_ip, ".", "-")}.sslip.io"
}

output "casdoor_url" {
  description = "Public Casdoor SSO URL"
  value       = "https://casdoor.${replace(aws_eip.lobechat.public_ip, ".", "-")}.sslip.io"
}

output "minio_url" {
  description = "Public MinIO S3 API URL"
  value       = "https://minio.${replace(aws_eip.lobechat.public_ip, ".", "-")}.sslip.io"
}

output "ssh_command" {
  description = "SSH command to connect (add your key pair if needed)"
  value       = "ssh ubuntu@${aws_eip.lobechat.public_ip}"
}
