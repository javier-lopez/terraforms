resource "digitalocean_droplet" "www-1" {
    image = "ubuntu-16-04-x64"
    name = "www-1"
    region = "SFO1"
    size = "512mb"
    private_networking = true
    ssh_keys = [
      "${var.ssh_fingerprint}"
]

connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
  }

provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "sudo apt-get update",
      "sudo apt-get -y install nginx",
      "echo 'hola mundo' | sudo tee /var/www/html/index.html"
    ]
  }
}
