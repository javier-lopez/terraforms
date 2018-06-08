resource "digitalocean_droplet" "mn" {
    count    = "1"
    name     = "${format("mn-%02d", count.index)}"
    region   = "sfo2"
    image    = "ubuntu-16-04-x64"
    size     = "s-1vcpu-1gb"
    private_networking = true

    ssh_keys = ["${digitalocean_ssh_key.mn-key.id}"]

    connection {
        user        = "root"
        type        = "ssh"
        private_key = "${file(var.private_key)}"
        timeout     = "2m"
    }

    provisioner "remote-exec" {
        script = "provision/01-disable-unattended-upgrades.sh"
    }

    provisioner "remote-exec" {
        script = "provision/02-install-ansible-deps.sh"
    }
}

output "mn-output" {
  value = "${digitalocean_droplet.mn.*.ipv4_address}"
}
