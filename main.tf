# Provider Configuration
provider "aws" {
  region = "us-east-1"  
}

# Generate SSH Key Pair for Ansible
resource "aws_key_pair" "drupal_key" {
  key_name   = "drupal-key"
  public_key = file("~/.ssh/id_rsa.pub")  # Make sure you have your public key in this path
}

# Security Group Configuration
resource "aws_security_group" "allow_ssh_http" {
  name = "allow-ssh-http"
  description = "Allow SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance Configuration
resource "aws_instance" "web_server" {
  ami             = "ami-0e2c8caa4b6378d8c"  
  instance_type   = "t2.micro"  
  key_name        = aws_key_pair.drupal_key.key_name
  security_groups = [aws_security_group.allow_ssh_http.name]

  tags = {
    Name = "drupal-server"
  }

  # Provisioner to run remote-exec for initial setup
  provisioner "remote-exec" {
    inline = [
      "echo 'Provisioning EC2 instance!'"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }

 
}

# Create a Security Group for RDS instance
resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Security group for RDS instance"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow access to RDS from any IP address
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an RDS instance (MySQL)
resource "aws_db_instance" "default" {
  identifier        = "my-mysql-db"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"  # Use an appropriate size
  allocated_storage = 20
  storage_type      = "gp2"
  username          = "admin"
  password          = var.db_pass  # Use a variable for the password
  db_name           = "drupal"
  skip_final_snapshot = true
  publicly_accessible = true
  vpc_security_group_ids   = [aws_security_group.rds_sg.id]

  tags = {
    Name = "MySQL DB"
  }
}



 # Outputs the public IP
  output "instance_ip" {
    value = aws_instance.web_server.public_ip
  }

  output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}

