#export TF_VAR_sheepit_user=your-user
variable "sheepit_user" {
  description = "sheepit-renderfarm.com user"
  default     = "javier_io"
}

variable "sheepit_password" {}

#resource "aws_instance" "blender" {
resource "aws_spot_instance_request" "blender" {
    instance_type = "p2.xlarge"
    ami           = "${var.aws_ami}"
    spot_price    = "${var.aws_spot_price}"
    #spot_type    = "persistent"
    spot_type     = "one-time"
    wait_for_fulfillment = true
    #instance_interruption_behaviour = "hibernate"

    key_name      = "blender-key"
    vpc_security_group_ids = ["${aws_security_group.blender-sec-group.id}"]

    timeouts {
      create = "60m"
    }

    connection {
        user        = "ubuntu"
        #user       = "root"
        type        = "ssh"
        timeout     = "2m"
        private_key = "${file(var.private_key)}"
    }

    #disable unattended upgrades
    provisioner "remote-exec" {
        inline = [
            "set -xe",
            "echo 'APT::Periodic::Update-Package-Lists \"0\";' | tee    /etc/apt/apt.conf.d/51disable-unattended-upgrades",
            "echo 'APT::Periodic::Unattended-Upgrade   \"0\";' | tee -a /etc/apt/apt.conf.d/51disable-unattended-upgrades",
            "sudo systemctl stop apt-daily.timer",
            "sudo systemctl disable apt-daily.timer",
            "sudo systemctl disable apt-daily.service",
            "sudo systemctl daemon-reload"
        ]
    }

    #https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/optimize_gpu.html
    provisioner "remote-exec" {
        inline = [
            "set -xe",
            "sudo nvidia-persistenced",
            "sudo nvidia-smi --auto-boost-default=0",
            "sudo nvidia-smi -ac 2505,875"    #p2 instances
            #"sudo nvidia-smi -ac 877,1530",  #p3 instances
            #"sudo nvidia-smi -ac 2505,1177", #g3 instances
        ]
    }

    provisioner "remote-exec" {
        inline = [
            "set -xe",
            "export USERNAME=${var.sheepit_user}",
            "export PASSWORD=${var.sheepit_password}",
            "sudo add-apt-repository ppa:thomas-schiex/blender -y",
            "sudo apt-get update",
            "sudo apt-get install libglu1-mesa libsm-dev blender default-jre -y",
            "sudo wget http://sheepit-renderfarm.com/media/applet/client-latest.php -O /usr/bin/sheepit.jar",
            "nohup java -jar /usr/bin/sheepit.jar -login $USERNAME -password $PASSWORD -ui text -compute-method GPU -gpu CUDA_0 &",
            "sleep 30s",
            "cat ~/nohup.out"
        ]
    }

    #provisioner "remote-exec" {
        #inline = [
            ##echo executed cmds
            #"set -xe",
            ##install ansible deps
            #"apt-get -y install python python-pip sudo",
            ##enable passwordless sudo wheel group
            #"addgroup wheel",
            #"echo '%wheel ALL = (ALL) NOPASSWD: ALL' | tee /etc/sudoers.d/wheel",
            ##create ansible user
            #"adduser --quiet --disabled-password --shell /bin/bash --home /home/ansible --gecos 'User' ansible",
            #"echo 'ansible:ansible.ansible.ansible.ansible.ansible' | chpasswd",
            #"usermod -a -G wheel ansible",
            ##enable ssh access
            #"mkdir /home/ansible/.ssh",
            #"cp -r ~/.ssh/authorized_keys /home/ansible/.ssh/authorized_keys",
            #"chown -R ansible:ansible /home/ansible/.ssh"
        #]
    #}

    #provisioner "remote-exec" {
        #script = "provision/01-install-mn.sh"
    #}

    #provisioner "local-exec" {
        #command = <<EOT
          #cd provision/ansible/ &&
          #ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook ansible.yml \
          #-i ${digitalocean_droplet.mn.ipv4_address}, \
          #-u ansible --private-key=~/.ssh/id_rsa      \
          #--vault-password-file=.vault_pass.txt       \
          #--extra-vars=@inventories/prod/group_vars/all/vars.yml
#EOT
    #}

    #provisioner "remote-exec" {
        #inline = [
            ##echo executed cmds
            #"set -xe",
            ##install obfuscator deps
            #"apt-get -y install binutils"
        #]
    #}

    #provisioner "remote-exec" {
        #script = "provision/99-obfuscate-ansible-password.sh"
    #}

    tags {
        Name = "blender"
    }
}

resource "aws_security_group" "blender-sec-group" {
    name = "Allow SSH and outgoing network connections"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    #allow outgoing network connections
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "blender"
    }
}

resource "aws_key_pair" "blender-key" {
  key_name   = "blender-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCshstNHlxe05HtVnwt5grpHsF4UwZYsBcn6eVgWPoYUPztktU0bv22JdqqPEPixIXqgYAxzsWioYjcnxsflgWzcly+DwS/8rt0Doa2+rw9i8JwmaHiXHO/wumRXENz7laayUPbuoEaz8w3k+1M5hfwO76WRHeKtakeghmc6gprRV8vwBha7DH32zj9z4auI/vxmkc73gIOAMWHoR//nKKBX+fRuD1MjzwwvJ3+HkA3YIsd87MishOOrWy6dlGzbW3BYhBCilJ1tAyz1GEw5Lj+Gydj2geK3P7i3sUDLuT4B4FYZaIKRvbUsvmaOayJcNofhdZPnR916OHqSfGzF4or javier@minos.lan"
}
