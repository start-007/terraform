provider "aws" {
  region = "us-east-1"

}

resource "aws_vpc" "development-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name: "development-vpc"
  }
}

resource "aws_subnet" "dev-subnet-1" {
  vpc_id = aws_vpc.development-vpc.id
  cidr_block = "10.0.10.0/24"
  availability_zone = "us-east-1a"

}
data "aws_vpc" "existing_vpc" {
  default = true
}

variable "subnet_cidr_block" {
  description = "subnet cidr block"
  
}
resource "aws_subnet" "dev-subnet-2" {
  vpc_id = data.aws_vpc.existing_vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = "us-east-1a"

}

output "dev-vpc-id" {
  value = aws_vpc.development-vpc.id
}