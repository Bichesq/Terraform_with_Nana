output "aws_ami_id" {
    value = module.server.webserver.ami
}

output "ec2_public_ip" {
  value = module.server.webserverserver.public_ip
}