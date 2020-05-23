resource "aws_instance" "webserver" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.aws_instance_type}"
  subnet_id              = "${aws_subnet.benchmarks.id}"
  vpc_security_group_ids = ["${aws_security_group.benchmarks.id}"]
  key_name               = "${var.ssh_keypair_name}"
  private_ip             = "192.168.0.10"

  tags = {
    Name = "webserver"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("./${var.ssh_keypair_name}.pem")}"
    host = "${self.public_ip}"
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

output "webserver_public_ip" {
  value = "${aws_instance.webserver.public_ip}"
}
