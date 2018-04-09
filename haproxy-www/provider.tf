#export TF_VAR_do_token=your-token
variable "do_token" {}

variable "ssh_fingerprint" {
  default = "78:80:7b:bc:b4:2c:3f:ab:d9:53:d9:02:7d:7e:dc:b5"
}

variable "public_key" {
  description = "SSH Public Key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_key" {
  description = "SSH Private Key"
  default     = "~/.ssh/id_rsa"
}

provider "digitalocean" {
  token = "${var.do_token}"
}
