terraform {
  required_version = "1.4.6"
}
provider "aws" {
  region = var.region
}

resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

module "server" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.myapp_vpc.id
  instance_type = var.instance_type
  pem_file_location = var.pem_file_location
  env_prefix = var.env_prefix
  key_pair_name = var.key_pair_name
}

module "subnet" {
  source = "./modules/subnet"
  vpc_id = aws_vpc.myapp_vpc.id
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
}