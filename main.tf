terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "zero_trust" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "zero-trust-vpc" }
}

# Public Subnet — Nginx
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.zero_trust.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = { Name = "zt-public-subnet" }
}

# Private Subnet — App Server
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.zero_trust.id
  cidr_block = "10.0.2.0/24"
  tags = { Name = "zt-private-subnet" }
}

# Security Group — Nginx
resource "aws_security_group" "nginx" {
  name   = "zt-nginx-sg"
  vpc_id = aws_vpc.zero_trust.id

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

# Security Group — App Server
resource "aws_security_group" "app" {
  name   = "zt-app-sg"
  vpc_id = aws_vpc.zero_trust.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.nginx.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
