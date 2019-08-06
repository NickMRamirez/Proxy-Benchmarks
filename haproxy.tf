resource "aws_instance" "haproxy" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.aws_instance_type}"
  subnet_id              = "${aws_subnet.benchmarks.id}"
  vpc_security_group_ids = ["${aws_security_group.benchmarks.id}"]
  key_name               = "${var.ssh_keypair_name}"
  depends_on             = ["aws_instance.webserver"]

  tags = {
    Name = "haproxy"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("./${var.ssh_keypair_name}.pem")}"
    host = "${self.public_ip}"
  }

  provisioner "file" {
    source      = "./haproxy/haproxy.cfg"
    destination = "/home/ubuntu/haproxy.cfg"
  }

  provisioner "file" {
    source      = "./haproxy/haproxy_setup.sh"
    destination = "/home/ubuntu/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /home/ubuntu/setup.sh",
        "sudo /home/ubuntu/setup.sh",
    ]
  }
}

output "haproxy_public_ip" {
  value = "${aws_instance.haproxy.public_ip}"
}
