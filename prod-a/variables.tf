variable "environment" { type = string }
variable "aws_ec2_key" { type = string }
variable "my_ip" { type = string }
variable "db_pass" { type = string }
variable "ec2_instance_type" { type = string }
variable "ec2_1a_tag" { type = string }
variable "ec2_1b_tag" { type = string }
variable "ec2_security_group_name" { type = string }
variable "ec2_security_group_description" { type = string }
variable "rds_instance_type" { type = string }
variable "rds_db_name" { type = string }
variable "rds_instance_tag" { type = string }
variable "rds_security_group_name" { type = string }
variable "rds_security_group_description" { type = string }
variable "alb_security_group_name" { type = string }
variable "alb_security_group_description" { type = string }
variable "vpc_name" { type = string }
variable "public_tag" { type = string }
variable "private_tag" { type = string }
variable "private_subnet_group_data" { type = string }
variable "alb_name" { type = string }
variable "tg_name" { type = string }
variable "subnet_az_1a" {
  type    = string
  default = "us-east-1a"
}

variable "subnet_az_1b" {
  type    = string
  default = "us-east-1b"
}