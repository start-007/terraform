provider "aws" {
  region = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key

}
variable "access_key" {
  
}
variable "secret_key" {
  
}
variable "vpc_cidr_block" {
  
}
variable "subnet_cidr_block" {
  
}
variable "avail_zone" {
  
}
variable "env_prefix" {
  
}
variable "instance-type" {
  
}
variable "ssh_key_path" {
  
}
resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags={
    Name: "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "my-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags={
    Name: "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "myapp-gateway" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags ={
    Name: "${var.env_prefix}-igw"
  }
}

resource "aws_default_route_table" "main-route-table" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-gateway.id
  }
  tags = {
    Name: "${var.env_prefix}-mai-rtb"
  }

}

resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.myapp-vpc.id
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
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
   tags = {
    Name: "${var.env_prefix}-default-sg"
  }
}
data "aws_ami" "last-ubuntu-image" {
    most_recent =true
     filter {
      name = "image-id"
      values = ["ami-0e2c8caa4b6378d8c"]
    }

}
resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  public_key = "${file(var.ssh_key_path)}"
}
resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.last-ubuntu-image.id
  instance_type = var.instance-type
  subnet_id = aws_subnet.my-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name
  user_data = file("entry_script.sh")
  tags = {
    Name: "${var.env_prefix}-server"
  }
}
output "ec2_public_ip" {
  value = aws_instance.myapp-server.public_ip
}

