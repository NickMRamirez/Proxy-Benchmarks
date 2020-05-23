resource "aws_instance" "envoy" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.aws_instance_type}"
  subnet_id              = "${aws_subnet.benchmarks.id}"
  vpc_security_group_ids = ["${aws_security_group.benchmarks.id}"]
  key_name               = "${var.ssh_keypair_name}"
  depends_on             = ["aws_instance.webserver"]

  tags = {
    Name = "envoy"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("./${var.ssh_keypair_name}.pem")}"
    host = "${self.public_ip}"
  }

  provisioner "file" {
    source      = "./envoy/envoy.yaml"
    destination = "/tmp/envoy.yaml"
  }

  provisioner "file" {
    source      = "./envoy/envoy_setup.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/setup.sh",
        "sudo /tmp/setup.sh",
    ]
  }
}

output "envoy_public_ip" {
  value = "${aws_instance.envoy.public_ip}"
}
