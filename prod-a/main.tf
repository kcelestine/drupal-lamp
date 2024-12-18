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

  backend "s3" {                                 # Path within the S3 bucket to store the state file
    region         = "us-east-1"                 # The region where the S3 bucket is located
    encrypt        = true                        # Encrypt the state file using SSE-S3
    dynamodb_table = "terraform-lock"            # DynamoDB table for state locking
    acl            = "bucket-owner-full-control" # Set ACL for the state file
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
resource "aws_instance" "ec2_1a" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.ec2_instance_type
  key_name               = var.aws_ec2_key
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id              = aws_subnet.public_us_east_1a.id

  tags = {
    Name = var.ec2_1a_tag
  }
}

# EC2 Instance Configuration
resource "aws_instance" "ec2_1b" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.ec2_instance_type
  key_name               = var.aws_ec2_key
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id              = aws_subnet.public_us_east_1b.id

  tags = {
    Name = var.ec2_1b_tag
  }
}

resource "random_id" "unique_id" {
  byte_length = 8
}

# Create an RDS instance (MySQL)
resource "aws_db_instance" "this" {
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
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.data.name

  tags = {
    Name = var.rds_instance_tag
  }
}

# Application Load Balancer (ALB)
resource "aws_lb" "prod" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_us_east_1a.id, aws_subnet.public_us_east_1b.id]

  enable_deletion_protection = false
  enable_http2               = true

  tags = {
    Name = var.alb_name
  }
}

# Step 6: Create a Target Group for the EC2 instance
resource "aws_lb_target_group" "prod" {
  name     = var.tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "HTTP"
  }

  tags = {
    Name = var.tg_name
  }
}

# Register EC2 instance with the Target Group
resource "aws_lb_target_group_attachment" "ec2_1a" {
  target_group_arn = aws_lb_target_group.prod.arn
  target_id        = aws_instance.ec2_1a.id
  port             = 80
}

# Register EC2 instance with the Target Group
resource "aws_lb_target_group_attachment" "ec2_1b" {
  target_group_arn = aws_lb_target_group.prod.arn
  target_id        = aws_instance.ec2_1b.id
  port             = 80
}

# ALB Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.prod.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod.arn
  }
}
