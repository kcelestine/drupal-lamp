# Provider Configuration
provider "aws" {
  region = "us-east-1"  
}

# Generate SSH Key Pair for Ansible
resource "aws_key_pair" "ansible_key" {
  key_name   = "ansible-key"
  public_key = file("~/.ssh/id_rsa.pub")  # Make sure you have your public key in this path
}

# Security Group Configuration
resource "aws_security_group" "allow_ssh_http" {
  name_prefix = "allow-ssh-http-"
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
  key_name        = aws_key_pair.ansible_key.key_name
  security_groups = [aws_security_group.allow_ssh_http.name]

  tags = {
    Name = "web-server"
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

 # Outputs the public IP
  output "instance_ip" {
    value = aws_instance.web_server.public_ip
  }