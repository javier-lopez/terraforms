resource "digitalocean_droplet" "docker-worker" {
    count    = "3"
    image    = "ubuntu-16-04-x64"
    name     = "docker-worker.${count.index+1}"
    region   = "sfo2"
    size     = "512mb"
    ssh_keys = [ "${var.ssh_fingerprint}" ]
    private_networking = true

    connection {
        user        = "root"
        type        = "ssh"
        timeout     = "2m"
        private_key = "${file(var.private_key)}"
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
            #join swarm
            "docker swarm join --token ${data.external.docker-manager-swarm-tokens.result.worker} ${digitalocean_droplet.docker-manager.ipv4_address_private}:2377"
        ]
    }
}
