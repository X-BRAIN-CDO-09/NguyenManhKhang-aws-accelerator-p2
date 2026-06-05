terraform {
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    null = {
      source = "hashicorp/null"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}


provider "aws" {
  region = var.aws_region
}

provider "null" {}

provider "tls" {}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key" {
  key_name   = var.key_name
  public_key = tls_private_key.pk.public_key_openssh 
}

#################################################
# VPC
#################################################

resource "aws_vpc" "main" {

  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "minikube-vpc"
  }
}

#################################################
# SUBNET A
#################################################

resource "aws_subnet" "public_a" {

  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.1.0/24"

  map_public_ip_on_launch = true

  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "public-a"
  }
}

#################################################
# SUBNET B
#################################################

resource "aws_subnet" "public_b" {

  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.2.0/24"

  map_public_ip_on_launch = true

  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "public-b"
  }
}

#################################################
# INTERNET GATEWAY
#################################################

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.main.id
}

#################################################
# ROUTE TABLE
#################################################

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_a" {

  subnet_id = aws_subnet.public_a.id

  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {

  subnet_id = aws_subnet.public_b.id

  route_table_id = aws_route_table.public.id
}

#################################################
# SECURITY GROUP
#################################################

resource "aws_security_group" "minikube" {

  name = "minikube-sg"

  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 30080
    to_port   = 30080
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {

    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

#################################################
# UBUNTU AMI
#################################################

data "aws_ami" "ubuntu" {

  most_recent = true

  owners = ["099720109477"]

  filter {

    name = "name"

    values = [
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    ]
  }
}

#################################################
# EC2
#################################################

resource "aws_instance" "minikube" {

  ami = data.aws_ami.ubuntu.id

  instance_type = var.instance_type

  subnet_id = aws_subnet.public_a.id

  associate_public_ip_address = true

  key_name = aws_key_pair.key.key_name

  vpc_security_group_ids = [
    aws_security_group.minikube.id
  ]

  tags = {
    Name = "minikube-node"
  }
}

#################################################
# ALB
#################################################

resource "aws_lb" "app_alb" {

  name = "minikube-alb"

  internal = false

  load_balancer_type = "application"

  security_groups = [
    aws_security_group.minikube.id
  ]

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  tags = {
    Name = "minikube-alb"
  }
}

#################################################
# TARGET GROUP
#################################################

resource "aws_lb_target_group" "app" {

  name = "nginx-tg"

  port = 30080

  protocol = "HTTP"

  vpc_id = aws_vpc.main.id

  target_type = "instance"

  health_check {

    enabled = true

    path = "/"

    protocol = "HTTP"

    matcher = "200"

    interval = 30

    timeout = 5

    healthy_threshold = 2

    unhealthy_threshold = 2
  }
}

#################################################
# TARGET ATTACHMENT
#################################################

resource "aws_lb_target_group_attachment" "app" {

  target_group_arn = aws_lb_target_group.app.arn

  target_id = aws_instance.minikube.id

  port = 30080
}

#################################################
# LISTENER
#################################################

resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.app_alb.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.app.arn
  }
}

#################################################
# BOOTSTRAP
#################################################

resource "null_resource" "bootstrap" {

  depends_on = [
    aws_instance.minikube
  ]

  connection {

    type = "ssh"

    user = "ubuntu"

    host = aws_instance.minikube.public_ip

    private_key = tls_private_key.pk.private_key_pem
  }

  provisioner "file" {

    source = "scripts/install.sh"

    destination = "/home/ubuntu/install.sh"
  }

  provisioner "file" {

    source = "scripts/deploy-app.sh"

    destination = "/home/ubuntu/deploy-app.sh"
  }

  provisioner "file" {

    source = "kubernetes/deployment.yaml"

    destination = "/home/ubuntu/deployment.yaml"
  }

  provisioner "file" {

    source = "kubernetes/service.yaml"

    destination = "/home/ubuntu/service.yaml"
  }

  provisioner "remote-exec" {

    inline = [

      "chmod +x /home/ubuntu/install.sh",

      "/home/ubuntu/install.sh",

      "chmod +x /home/ubuntu/deploy-app.sh",

      "/home/ubuntu/deploy-app.sh"
    ]
  }
}