variable "aws_ec2_key" {
  type = string
}

variable "my_ip" {
  type = string
}

variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ec2_instance_tag" {
  type    = string
  default = "drupal-server"
}

variable "ec2_security_group_name" {
  type    = string
  default = "drupal-sg-app"
}

variable "ec2_security_group_description" {
  type    = string
  default = "Security group for EC2 instance"
}

variable "rds_instance_type" {
  type    = string
  default = "db.t3.micro"
}

variable "rds_db_name" {
  type    = string
  default = "drupal"
}

variable "db_pass" {
  type = string
}

variable "rds_instance_tag" {
  type    = string
  default = "drupal-db"
}

variable "rds_security_group_name" {
  type    = string
  default = "drupal-sg-data"
}

variable "rds_security_group_description" {
  type    = string
  default = "Security group for RDS instance"
}

variable "alb_security_group_name" {
  type    = string
  default = "drupal-sg-alb"
}

variable "alb_security_group_description" {
  type    = string
  default = "Security group for ALB"
}

variable "vpc_name" {
  type    = string
  default = "drupal-vpc"
}

variable "subnet_az_1a" {
  type    = string
  default = "us-east-1a"
}

variable "subnet_az_1b" {
  type    = string
  default = "us-east-1b"
}

variable "public_tag" {
  type    = string
  default = "drupal-public"
}

variable "private_tag" {
  type    = string
  default = "drupal-private"
}

variable "private_subnet_group_data" {
  type    = string
  default = "drupal-private-data"
}