provider "aws" {
  region = var.region
}

# Grab your default AWS VPC
data "aws_vpc" "default" {
  default = true
}

# Simple security group for SSH, HTTP, and HTTPS
resource "aws_security_group" "sg" {
  name   = "web-ssh-sg-01"
  vpc_id = data.aws_vpc.default.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic so the VM can reach the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# The Virtual Machine
resource "aws_instance" "vm" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "sampleVM"
  }
}
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_dynamodb_table" "basic_table" {
  name         = "AppStorage"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id" # Mandatory partition key placeholder

  attribute {
    name = "id"
    type = "S" # String type (can hold UUIDs, auto-generated IDs, etc.)
  }
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.basic_table.name
  description = "The name of the DynamoDB table"
}

# 1. Create the S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "sanju-bucket-sample-01" # Must be globally unique

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}
