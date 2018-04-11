#export TF_VAR_aws_access_key=your-token
variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aws_spot_price" {
  description = "AWS spot price."
  #slighly overpriced, run cheapest-aws-gpu-spot-instance.sh script to ensure you're paying the lowest price
  default     = "0.40"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1" #virginia
  #default    = "us-east-2" #ohio
  #default    = "us-west-2" #oregon
}

#export TF_VAR_aws_ami=ami-id
variable "aws_ami" {
  description = "AWS AMI id"
  default     = "ami-bc09d9c1" #virgina
  #ami        = "ami-5b22133e" #ohio
  #ami        = "ami-d2c759aa" #oregon
}

variable "public_key" {
  description = "SSH Public Key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_key" {
  description = "SSH Private Key"
  default     = "~/.ssh/id_rsa"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}
