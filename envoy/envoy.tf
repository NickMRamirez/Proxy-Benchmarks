variable "proxy_server_public_ip" {
  type = string
}

variable "ssh_keypair_name" {
  type = string
}

resource "null_resource" "envoy" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./${var.ssh_keypair_name}.pem")
    host = var.proxy_server_public_ip
  }

  provisioner "file" {
    source      = "./envoy/envoy.yaml"
    destination = "/tmp/envoy.yaml"
  }

  provisioner "file" {
    source      = "./envoy/envoy_setup.sh"
    destination = "/tmp/envoy_setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/envoy_setup.sh",
        "sudo /tmp/envoy_setup.sh",
    ]
  }
}
