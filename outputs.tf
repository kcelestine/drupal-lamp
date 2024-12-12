# Outputs the public IP
output "instance_ip" {
  value = aws_instance.web_server.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.drupal_rds.endpoint
}

output "loadbalancer_endpoint" {
  value = aws_lb.drupal_alb.dns_name
  description = "The DNS name of the Application Load Balancer"
}