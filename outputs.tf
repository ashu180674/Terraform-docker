output "public_ip" {
  value = "http://${aws_instance.ec2_instance.public_ip}:8081/api/v1"
}
