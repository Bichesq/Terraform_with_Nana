terraform {
  required_version = "1.4.6"
}
provider "aws" {
  region = "eu-central-1"
}
variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable instance_type {}
variable pem_file_location {}


resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp_subnet-1" {
  vpc_id = aws_vpc.myapp_vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

resource "aws_route_table" "myapp_route_table" {
  vpc_id = aws_vpc.myapp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_igw.id
  }
  tags = {
    Name: "${var.env_prefix}-rtb"
  }
}

resource "aws_internet_gateway" "myapp_igw" {
  vpc_id = aws_vpc.myapp_vpc.id

  tags = {
    Name: "${var.env_prefix}-igw"
  }
 
}

resource "aws_route_table_association" "a_rtb_subnet" {
  subnet_id = aws_subnet.myapp_subnet-1.id
  route_table_id = aws_route_table.myapp_route_table.id

}

resource "aws_security_group" "myapp_sg" {
  name = "myapp_sg"
  vpc_id = aws_vpc.myapp_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name: "${var.env_prefix}-sg"
  }
}

data "aws_ami" "latest_amazon_linux_image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
    }

   /* filter {
        name = "Virtualization-type"
        values = ["hvm"]
    }*/
}

output "aws_ami_id" {
    value = data.aws_ami.latest_amazon_linux_image.id
}

output "ec2_public_ip" {
  value = aws_instance.myapp_instance.public_ip
}

resource "aws_key_pair" "myapp_server_key" {
  key_name = "Demo-key"
  public_key = tls_private_key.key.public_key_openssh
}


resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "Demo-key" {
  content = "this is my pem file"
  filename = var.pem_file_location
  file_permission = "0777"
}

resource "aws_instance" "myapp_instance" {
  ami = "ami-0094635555ed28881"
 # ami = data.aws_ami.latest_amazon_linux_image.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.myapp_subnet-1.id
  vpc_security_group_ids = [aws_security_group.myapp_sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = "dev-prod"
 # key_name = aws_key_pair.myapp_server_key.key_name

 user_data = file("script.sh")
 
 tags = {
    Name: "${var.env_prefix}-server"
  }
}