variable "proxy_server_public_ip" {
  type = string
}

variable "ssh_keypair_name" {
  type = string
}

resource "null_resource" "nginx" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./${var.ssh_keypair_name}.pem")
    host = var.proxy_server_public_ip
  }

  provisioner "file" {
    source      = "./nginx/nginx.conf"
    destination = "/tmp/nginx.conf"
  }

  provisioner "file" {
    source      = "./nginx/nginx_setup.sh"
    destination = "/tmp/nginx_setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/nginx_setup.sh",
        "sudo /tmp/nginx_setup.sh",
    ]
  }
}
