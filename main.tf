provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
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
  vpc_id                  = aws_vpc.benchmarks.id
  cidr_block              = "192.168.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "benchmarks" {
  vpc_id = aws_vpc.benchmarks.id
}

resource "aws_route_table" "benchmarks" {
  vpc_id = aws_vpc.benchmarks.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.benchmarks.id
  }
}

resource "aws_route_table_association" "benchmarks" {
  route_table_id = aws_route_table.benchmarks.id
  subnet_id      = aws_subnet.benchmarks.id
}

resource "aws_security_group" "benchmarks" {
  name        = "benchmarks_security_group"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.benchmarks.id

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
    from_port   = 8000
    to_port     = 8010
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


# -----------------------------------------------------------------
#                     client server
# -----------------------------------------------------------------
resource "aws_instance" "client" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.benchmarks.id
  vpc_security_group_ids = [aws_security_group.benchmarks.id]
  key_name               = var.ssh_keypair_name

  tags = {
    Name = "client"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./${var.ssh_keypair_name}.pem")
    host = self.public_ip
  }

  provisioner "file" {
    source      = "./client/client_setup.sh"
    destination = "/tmp/client_setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/client_setup.sh",
        "sudo /tmp/client_setup.sh",
    ]
  }
}

output "client" {
    value = "ssh -i ./benchmarks.pem ubuntu@${aws_instance.client.public_ip}"
}


# -----------------------------------------------------------------
#                     web server
# -----------------------------------------------------------------
resource "aws_instance" "webserver" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.benchmarks.id
  vpc_security_group_ids = [aws_security_group.benchmarks.id]
  key_name               = var.ssh_keypair_name
  private_ip             = "192.168.0.10"

  tags = {
    Name = "webserver"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./${var.ssh_keypair_name}.pem")
    host = self.public_ip
  }

  provisioner "file" {
    source = "./webserver/docker-compose.yml"
    destination = "/tmp/docker-compose.yml"
  }

  provisioner "file" {
    source      = "./webserver/webserver_setup.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/setup.sh",
        "sudo /tmp/setup.sh",
    ]
  }
}


# -----------------------------------------------------------------
#                     proxy server
# -----------------------------------------------------------------
resource "aws_instance" "proxy_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.benchmarks.id
  vpc_security_group_ids = [aws_security_group.benchmarks.id]
  key_name               = var.ssh_keypair_name
  depends_on             = [aws_instance.webserver]

  tags = {
    Name = "proxy_server"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./${var.ssh_keypair_name}.pem")
    host = aws_instance.proxy_server.public_ip
  }

  provisioner "file" {
    source      = "./docker/docker_setup.sh"
    destination = "/tmp/docker_setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/docker_setup.sh",
        "sudo /tmp/docker_setup.sh",
    ]
  }
}

# -----------------------------------------------------------------
#                     caddy
# -----------------------------------------------------------------
module "caddy" {
  source = "./caddy"
  proxy_server_public_ip = aws_instance.proxy_server.public_ip
  ssh_keypair_name = var.ssh_keypair_name
}

output "caddy" {
    value = "http://${aws_instance.proxy_server.public_ip}:8000"
}

# -----------------------------------------------------------------
#                     envoy
# -----------------------------------------------------------------
module "envoy" {
  source = "./envoy"
  proxy_server_public_ip = aws_instance.proxy_server.public_ip
  ssh_keypair_name = var.ssh_keypair_name
}

output "envoy" {
    value = "http://${aws_instance.proxy_server.public_ip}:8001"
}

# -----------------------------------------------------------------
#                     haproxy
# -----------------------------------------------------------------
module "haproxy" {
  source = "./haproxy"
  proxy_server_public_ip = aws_instance.proxy_server.public_ip
  ssh_keypair_name = var.ssh_keypair_name
}

output "haproxy" {
    value = "http://${aws_instance.proxy_server.public_ip}:8002"
}


# -----------------------------------------------------------------
#                     nginx
# -----------------------------------------------------------------
module "nginx" {
  source = "./nginx"
  proxy_server_public_ip = aws_instance.proxy_server.public_ip
  ssh_keypair_name = var.ssh_keypair_name
}

output "nginx" {
    value = "http://${aws_instance.proxy_server.public_ip}:8003"
}

# -----------------------------------------------------------------
#                     traefik
# -----------------------------------------------------------------
module "traefik" {
  source = "./traefik"
  proxy_server_public_ip = aws_instance.proxy_server.public_ip
  ssh_keypair_name = var.ssh_keypair_name
}

output "traefik" {
    value = "http://${aws_instance.proxy_server.public_ip}:8004"
}
