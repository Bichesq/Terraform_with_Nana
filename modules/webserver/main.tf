resource "aws_security_group" "myapp_sg" {
  name = "myapp_sg"
  vpc_id = var.vpc_id

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
# Amazon Linus 2
data "aws_ami" "latest_amazon_linux_image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
    }

   filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name = "creation_data"
        values = ["2023-06-13"]
    }
}

/* resource "aws_key_pair" "myapp_server_key" {
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
} */

resource "aws_instance" "myapp_instance" {
#   ami = "ami-0094635555ed28881"
  ami = data.aws_ami.latest_amazon_linux_image.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.myapp_subnet-1.id
  vpc_security_group_ids = [aws_security_group.myapp_sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = var.key_pair_name
 # key_name = aws_key_pair.myapp_server_key.key_name

 user_data = file("script.sh")
 
 tags = {
    Name: "${var.env_prefix}-server"
  }
}