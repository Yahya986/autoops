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

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security group for EC2 instances
resource "aws_security_group" "autoops_sg" {
  name        = "autoops-sg"
  description = "Allow SSH, HTTP, and monitoring"

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
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
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

# Security group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "autoops-alb-sg"
  description = "Allow HTTP to ALB"

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

# Launch template
resource "aws_launch_template" "autoops" {
  name_prefix   = "autoops-"
  image_id      = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  key_name      = "autoops-key"

  vpc_security_group_ids = [aws_security_group.autoops_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker git
    service docker start
    usermod -a -G docker ec2-user
    git clone https://github.com/Yahya986/autoops.git /home/ec2-user/autoops
    cd /home/ec2-user/autoops
    docker build -t autoops-app ./app
    docker run -d --name autoops-app --restart always -p 80:80 autoops-app
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "autoops-server"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "autoops" {
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns   = [aws_lb_target_group.autoops.arn]

  launch_template {
    id      = aws_launch_template.autoops.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "autoops-server"
    propagate_at_launch = true
  }
}

# Application Load Balancer
resource "aws_lb" "autoops" {
  name               = "autoops-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default.ids
}

# Target Group
resource "aws_lb_target_group" "autoops" {
  name     = "autoops-tg"
  port     = 80
          protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }
}

# ALB Listener
resource "aws_lb_listener" "autoops" {
  load_balancer_arn = aws_lb.autoops.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.autoops.arn
  }
}

output "load_balancer_dns" {
  value = aws_lb.autoops.dns_name
}