variable "proxy_server_public_ip" {
  type = string
}

variable "ssh_keypair_name" {
  type = string
}

resource "null_resource" "haproxy" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./${var.ssh_keypair_name}.pem")
    host = var.proxy_server_public_ip
  }

  provisioner "file" {
    source      = "./haproxy/haproxy.cfg"
    destination = "/tmp/haproxy.cfg"
  }

  provisioner "file" {
    source      = "./haproxy/haproxy_setup.sh"
    destination = "/tmp/haproxy_setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/haproxy_setup.sh",
        "sudo /tmp/haproxy_setup.sh",
    ]
  }
}
