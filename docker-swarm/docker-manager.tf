resource "digitalocean_droplet" "docker-manager" {
    count    = "1"
    image    = "ubuntu-16-04-x64"
    name     = "docker-manager.${count.index+1}"
    region   = "sfo2"
    size     = "512mb"
    ssh_keys = [ "${var.ssh_fingerprint}" ]
    private_networking = true

    connection {
        user        = "root"
        type        = "ssh"
        timeout     = "2m"
        private_key = "${file(var.pvt_key)}"
    }

    provisioner "remote-exec" {
        inline = [
            #echo executed cmds
            "set -x",
            #install ansible deps
            #"apt-get -y update && apt-get -y install python python-pip sudo",
            #enable passwordless sudo wheel group
            "addgroup wheel",
            "echo '%wheel ALL = (ALL) NOPASSWD: ALL' | tee /etc/sudoers.d/wheel",
            #create docker user
            "adduser --quiet --disabled-password --shell /bin/bash --home /home/docker --gecos 'User' docker",
            "echo 'docker:docker' | chpasswd",
            "usermod -a -G wheel docker",
            #enable ssh access
            "mkdir /home/docker/.ssh",
            "cp -r ~/.ssh/authorized_keys /home/docker/.ssh/authorized_keys",
            "chown -R docker:docker /home/docker/.ssh"
        ]
    }

    provisioner "remote-exec" {
        script = "provision/01-install-docker.sh"
    }

    provisioner "remote-exec" {
        inline = [
            #echo executed cmds
            "set -x",
            "docker swarm init --advertise-addr ${digitalocean_droplet.docker-manager.ipv4_address_private}"
      ]
    }
}

data "external" "docker-manager-swarm-tokens" {
    program = ["provision/02-get-docker-manager-swarm-tokens.sh"]
    query = {
        host = "${digitalocean_droplet.docker-manager.ipv4_address}"
    }
    depends_on = ["digitalocean_droplet.docker-manager"]
}
