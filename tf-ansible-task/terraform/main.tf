provider "aws" {
  region = "us-east-2"
}
############################################
### Filtering AWS AMI with Ubuntu 20.04 ####
############################################
data "aws_ami" "ubuntu" {

    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["amazon"]
}

############################################
### SSH Key Pair for EC2 Authentication ####
############################################
resource "aws_key_pair" "ec2_key_pair" {

  key_name   = "takehomechallenge_pubkey"
  public_key = file("../resources/keys/id_rsa.pub")

}

############################################
#### Security Group to Allow 22 and 443 ####
############################################
resource "aws_security_group" "ec2_security_group" {

  name        = "takehomechallenge-sg"
  description = "Security group for the Take Home Challenge."

  ingress {
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    description = "Allow TCP port 22 access for accessing the instance."
  }

  ingress {
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    description = "Allow TCP port 443 access for accessing the instance."
  }

}

############################################
##### T2 Micro Ubuntu AWS EC2 Insance ######
############################################
resource "aws_instance" "takehomechallenge_ec2" {

    ami                     = data.aws_ami.ubuntu.id
    instance_type           = "t2.micro"
    vpc_security_group_ids  = [aws_security_group.ec2_security_group.id]
    key_name                = aws_key_pair.ec2_key_pair.key_name

}

############################################
###### Export EC2 instance private IP ######
########## to an Ansible var_file ##########
############################################
resource "local_file" "tf_ansible_vars_file_new" {

  content = <<-DOC
    # Ansible vars_file containing variable values from Terraform.

    ec2_public_dns: ${aws_instance.takehomechallenge_ec2.public_dns}
    DOC
  filename = "../ansible/tf_ansible_vars_file.yml"

}