provider "aws" {
  region     = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server*"]
  }

  owners = ["099720109477"]
}

resource "aws_vpc" "benchmarks" {
  cidr_block           = "192.168.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
}

resource "aws_subnet" "benchmarks" {
  vpc_id                  = "${aws_vpc.benchmarks.id}"
  cidr_block              = "192.168.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "benchmarks" {
  vpc_id = "${aws_vpc.benchmarks.id}"
}

resource "aws_route_table" "benchmarks" {
  vpc_id = "${aws_vpc.benchmarks.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.benchmarks.id}"
  }
}

resource "aws_route_table_association" "benchmarks" {
  route_table_id = "${aws_route_table.benchmarks.id}"
  subnet_id      = "${aws_subnet.benchmarks.id}"
}

resource "aws_security_group" "benchmarks" {
  name        = "benchmarks_security_group"
  description = "Allow HTTP and SSH"
  vpc_id      = "${aws_vpc.benchmarks.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
