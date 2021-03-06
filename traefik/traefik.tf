variable "proxy_server_public_ip" {
  type = string
}

variable "ssh_keypair_name" {
  type = string
}

resource "null_resource" "traefik" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./${var.ssh_keypair_name}.pem")
    host = var.proxy_server_public_ip
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
    destination = "/tmp/traefik_setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/traefik_setup.sh",
        "sudo /tmp/traefik_setup.sh",
    ]
  }
}
