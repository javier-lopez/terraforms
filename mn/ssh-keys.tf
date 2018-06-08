resource "digitalocean_ssh_key" "mn-key" {
  name       = "MN ssh key"
  public_key = "${file(var.public_key)}"
}
