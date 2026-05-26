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

resource "aws_instance" "autoops_server" {
  ami           = "ami-0c02fb55956c7d316"  # Amazon Linux 2 (us-east-1)
  instance_type = "t3.micro"               # Free tier!

  tags = {
    Name = "autoops-server"
  }
}