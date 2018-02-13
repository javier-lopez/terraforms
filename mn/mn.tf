resource "digitalocean_droplet" "mn" {
    count    = "1"
    image    = "ubuntu-16-04-x64"
    name     = "mn.memetic.${count.index+1}"
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
            #create ansible user
            "adduser --quiet --disabled-password --shell /bin/bash --home /home/ansible --gecos 'User' ansible",
            "echo 'ansible:ansible' | chpasswd",
            "usermod -a -G wheel ansible",
            #enable ssh access
            "mkdir /home/ansible/.ssh",
            "cp -r ~/.ssh/authorized_keys /home/ansible/.ssh/authorized_keys",
            "chown -R ansible:ansible /home/ansible/.ssh"
        ]
    }

    provisioner "remote-exec" {
        script = "provision/01-install-mn.sh"
    }

    provisioner "remote-exec" {
        script = "provision/99-obfuscate-ansible-password.sh"
    }
}
