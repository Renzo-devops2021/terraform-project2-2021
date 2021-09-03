variable "ami" {
  type = map(any)

}

variable "ingress_ports" {
  type = list(any)

}
variable "egress_ports" {
  type = list(any)


}

variable "tags" {
  type = list(any)

}

variable "region" {
  default = "us-east-2"

}
variable "public_key_location" {}

variable "instance_type" {
  type = list(any)

}