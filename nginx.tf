resource "aws_instance" "nginx" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.aws_instance_type}"
  subnet_id              = "${aws_subnet.benchmarks.id}"
  vpc_security_group_ids = ["${aws_security_group.benchmarks.id}"]
  key_name               = "${var.ssh_keypair_name}"
  depends_on             = ["aws_instance.webserver"]

  tags = {
    Name = "nginx"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("./${var.ssh_keypair_name}.pem")}"
    host = "${self.public_ip}"
  }

  provisioner "file" {
    source      = "./nginx/nginx.conf"
    destination = "/tmp/nginx.conf"
  }

  provisioner "file" {
    source      = "./nginx/nginx_setup.sh"
    destination = "/home/ubuntu/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /home/ubuntu/setup.sh",
        "sudo /home/ubuntu/setup.sh",
    ]
  }
}

output "nginx_public_ip" {
  value = "${aws_instance.nginx.public_ip}"
}
