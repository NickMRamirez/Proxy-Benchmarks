variable "proxy_server_public_ip" {
  type = string
}

variable "ssh_keypair_name" {
  type = string
}

resource "null_resource" "caddy" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./${var.ssh_keypair_name}.pem")
    host = var.proxy_server_public_ip
  }

  provisioner "file" {
    source      = "./caddy/Caddyfile"
    destination = "/tmp/Caddyfile"
  }

  provisioner "file" {
    source      = "./caddy/caddy_setup.sh"
    destination = "/tmp/caddy_setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/caddy_setup.sh",
        "sudo /tmp/caddy_setup.sh",
    ]
  }
}
