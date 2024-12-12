# Outputs the public IP
output "instance_ip" {
  value = aws_instance.this.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "loadbalancer_endpoint" {
  value = aws_lb.this.dns_name
}