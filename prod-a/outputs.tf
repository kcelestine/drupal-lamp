# Outputs the public IP
output "ec2_public_ip_1a" {
  value = aws_instance.ec2_1a.public_ip
}

output "ec2_public_ip_1b" {
  value = aws_instance.ec2_1b.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "loadbalancer_endpoint" {
  value = aws_lb.prod.dns_name
}