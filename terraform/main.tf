#bloco terraform, onde é definido a versão do terraform e o provider utilizado.
terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.92"
        }
    }
    required_version = ">= 1.2"
}

provider "aws" {
    region = "us-east-1"
}

#Security Group com regras de entrada
resource "aws_security_group" "ec2_sg"{
    name        = "ec2-security-group"
    description = "Permite SSH e HTTP"
    vpc_id      = data.aws_vpc.default.id

    ingress{
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "SSH"
    }

    ingress{
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP"
    }

    egress{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "All outbound"
    }

    tags = {
        Name = "ec2-security-group"
    }
}

# Buscar a VPC default
data "aws_vpc" "default" {
  default = true
}

# Buscar a subnet da VPC default
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "default" {
  id = data.aws_subnets.default.ids[0]
}

resource "aws_instance" "app_server"{
    ami                    = "ami-0779caf41f9ba54f0"
    instance_type          = "t2.micro"    
    key_name               = "iac-alura"
    vpc_security_group_ids = [aws_security_group.ec2_sg.id]
    subnet_id              = data.aws_subnet.default.id

    tags = {
        Name = "app_server"
    }
}