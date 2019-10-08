resource "aws_instance" "traefik" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.aws_instance_type}"
  subnet_id              = "${aws_subnet.benchmarks.id}"
  vpc_security_group_ids = ["${aws_security_group.benchmarks.id}"]
  key_name               = "${var.ssh_keypair_name}"
  depends_on             = ["aws_instance.webserver"]

  tags = {
    Name = "traefik"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("./${var.ssh_keypair_name}.pem")}"
    host = "${self.public_ip}"
  }

  provisioner "file" {
    source      = "./traefik/traefik.toml"
    destination = "/tmp/traefik.toml"
  }

  provisioner "file" {
      source      = "./traefik/dynamic_conf.toml"
      destination = "/tmp/dynamic_conf.toml"
  }

  provisioner "file" {
    source      = "./traefik/traefik_setup.sh"
    destination = "/home/ubuntu/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /home/ubuntu/setup.sh",
        "sudo /home/ubuntu/setup.sh",
    ]
  }
}

output "traefik_public_ip" {
  value = "${aws_instance.traefik.public_ip}"
}
