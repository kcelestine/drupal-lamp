# Create a VPC
resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = var.vpc_name
  }
}

# Create Subnets
resource "aws_subnet" "public_us_east_1a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.subnet_az_1a
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_tag
  }
}

resource "aws_subnet" "public_us_east_1b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.subnet_az_1b
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_tag
  }
}

resource "aws_subnet" "private_us_east_1a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.subnet_az_1a

  tags = {
    Name = var.private_tag
  }
}

resource "aws_subnet" "private_us_east_1b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.subnet_az_1b

  tags = {
    Name = var.private_tag
  }
}

resource "aws_db_subnet_group" "data" {
  name       = var.private_subnet_group_data
  subnet_ids = [aws_subnet.private_us_east_1a.id, aws_subnet.private_us_east_1b.id]

  tags = {
    Name = var.private_subnet_group_data
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = var.public_tag
  }
}

# Create Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = var.public_tag
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = var.private_tag
  }
}

# Associate Subnets with Route Tables
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_us_east_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_us_east_1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "alb" {
  name        = var.alb_security_group_name
  description = var.alb_security_group_description
  vpc_id      = aws_vpc.this.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
}

# Security Group for EC2 Instance
resource "aws_security_group" "ec2" {
  name        = var.ec2_security_group_name
  description = var.ec2_security_group_description
  vpc_id = aws_vpc.this.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for RDS instance
resource "aws_security_group" "rds" {
  name        = var.rds_security_group_name
  description = var.rds_security_group_description
  vpc_id = aws_vpc.this.id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

