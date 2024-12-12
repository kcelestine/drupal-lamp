terraform {

  required_version = "1.10.1"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "5.80.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

}

provider "random" {}

# Provider Configuration
provider "aws" {
  region = "us-east-1"
}



# Data Source for Latest Ubuntu 24 AMI
data "aws_ami" "ubuntu" {

  most_recent = true

  filter {
    name   = "name"
    values = ["*ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# EC2 Instance Configuration
resource "aws_instance" "web_server" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.ec2_instance_type
  key_name        = var.aws_ec2_key
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  subnet_id       = aws_subnet.public_subnet_1a.id

  tags = {
    Name = var.ec2_instance_tag
  }
}

resource "random_id" "unique_id" {
  byte_length = 8
}

# Create an RDS instance (MySQL)
resource "aws_db_instance" "drupal_rds" {
  identifier             = "drupal-db-${random_id.unique_id.hex}"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.rds_instance_type
  allocated_storage      = 20
  storage_type           = "gp2"
  username               = "admin"
  password               = var.db_pass
  db_name                = var.rds_db_name
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.drupal_data_subnet_group.name

  tags = {
    Name = var.rds_instance_tag
  }
}

# Application Load Balancer (ALB)
resource "aws_lb" "drupal_alb" {
  name               = "drupal-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1b.id]

  enable_deletion_protection = false
  enable_http2               = true

  tags = {
    Name = "drupal-alb"
  }
}

# Step 6: Create a Target Group for the EC2 instance
resource "aws_lb_target_group" "drupal_tg" {
  name     = "drupal-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "HTTP"
  }

  tags = {
    Name = "drupal-target-group"
  }
}

# Step 7: Register EC2 instance with the Target Group
# does this mean the traffic between the ec2 and alb or people trying to connect to alb too?
# see if I should keep this when I got to https
resource "aws_lb_target_group_attachment" "example" {
  target_group_arn = aws_lb_target_group.drupal_tg.arn
  target_id        = aws_instance.web_server.id
  port             = 80
}

# Step 8: Create an ALB Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.drupal_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.drupal_tg.arn
  }
}
