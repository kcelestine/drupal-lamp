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

variable "rds_security_group_name" {
  type    = string
  default = "rds-sg"
}

variable "rds_security_group_description" {
  type    = string
  default = "Security group for RDS instance"
}

variable "rds_instance_type" {
  type    = string
  default = "db.t3.micro"
}

variable "rds_db_name" {
  type    = string
  default = "drupal"
}

variable "rds_instance_tag" {
  type    = string
  default = "drupal-db"
}

variable "db_pass" {
  type = string
}

variable "vpc_name" {
  type    = string
  default = "drupal-vpc"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "subnet_az" {
  type    = string
  default = "us-east-1a"
}

variable "public_tag" {
  type    = string
  default = "public-drupal"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "private_tag" {
  type    = string
  default = "private-drupal"
}

variable "private_subnet_group" {
  type    = string
  default = "private-drupal"
}

variable "igw_tag" {
  type    = string
  default = "drupal-igw"
}