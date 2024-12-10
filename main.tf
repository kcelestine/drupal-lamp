# Main Terraform Configuration for AWS LAMP stack setup
provider "aws" {
  region = "us-east-1"  # Set the AWS region
}

resource "aws_instance" "lamp_stack" {
  ami           = "ami-0e2c8caa4b6378d8c"  # Ubuntu 24.04 
  instance_type = "t2.micro"  # Use t2.micro or another size based on requirements

  # User Data for installing LAMP stack
  user_data = <<-EOF
              #!/bin/bash
              # Update and install Apache, PHP, and MySQL
              apt-get update -y
              apt-get upgrade -y

              # Install Apache 2.4
              apt-get install -y apache2
              systemctl enable apache2
              systemctl start apache2

              # Install PHP 8.3
              add-apt-repository ppa:ondrej/php -y
              apt-get update -y
              apt-get install -y php8.3 php8.3-cli php8.3-fpm php8.3-mysql php8.3-xml php8.3-mbstring

              # Install MySQL 8.x (the latest stable MySQL version as 9.1.0 does not exist)
              apt-get install -y mysql-server
              systemctl enable mysql
              systemctl start mysql

              # Install common utilities
              apt-get install -y git curl unzip vim

              # Ensure Apache and PHP-FPM work together
              systemctl restart apache2
              EOF

  # Security group to allow HTTP (80), HTTPS (443) and SSH (22)
  security_groups = [aws_security_group.lamp_sg.name]

  # Tag for the instance
  tags = {
    Name = "LAMP Stack Server"
  }
}

# Security group for HTTP, HTTPS, and SSH access
resource "aws_security_group" "lamp_sg" {
  name        = "lamp-sg"
  description = "Security group for LAMP stack server"

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

  ingress {
    from_port   = 443
    to_port     = 443
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

output "instance_ip" {
  value = aws_instance.lamp_stack.public_ip
}
