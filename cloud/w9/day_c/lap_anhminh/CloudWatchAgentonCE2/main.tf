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
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "Lab-VPC" }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # Đảm bảo EC2 có IP Public để ra mạng

  tags = { Name = "Lab-Public-Subnet" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags   = { Name = "Lab-IGW" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "Lab-Public-RouteTable" }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_security_group" "ec2_sg" {
  name        = "allow_web_traffic"
  description = "Allow outbound traffic to download agent"
  vpc_id      = aws_vpc.main_vpc.id

  # Cho phép EC2 kết nối ra Internet để dùng lệnh wget tải package
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Lab-EC2-SG" }
}
# 1. TẠO IAM ROLE & INSTANCE PROFILE CHO EC2
resource "aws_iam_role" "ec2_cw_role" {
  name = "EC2_CloudWatch_Agent_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })
}

# Đính kèm Policy hệ thống bắt buộc để Agent đẩy dữ liệu về CloudWatch
resource "aws_iam_role_policy_attachment" "cw_policy_attach" {
  role       = aws_iam_role.ec2_cw_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2_CloudWatch_Profile"
  role = aws_iam_role.ec2_cw_role.name
}


# 2. KHỞI TẠO EC2 VÀ TỰ ĐỘNG CHẠY SCRIPT CÀI AGENT (User Data)
resource "aws_instance" "web_server" {
  ami                    = "ami-0152204c1a187337c"
  instance_type          = "t3.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data              = <<-EOF
              #!/bin/bash
              apt-get update -y
              wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
              dpkg -i -E ./amazon-cloudwatch-agent.deb
              systemctl enable amazon-cloudwatch-agent
              systemctl start amazon-cloudwatch-agent
              EOF

  tags = {
    Name = "EC2-With-CloudWatch-Agent"
  }
}

# Output ID của EC2 để dùng cho bài sau nếu cần
output "ec2_instance_id" {
  value       = aws_instance.web_server.id
  description = "ID cua EC2 vừa tao"
}
