
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

###################################
# Public subnet Variables
variable "pub_subnet_01_cidr" {
  type    = string
  default = "10.0.0.0/24"
}
variable "pub_subnet_01_az" {
  type    = string
  default = "us-east-1a"
}
variable "pub_subnet_02_cidr" {
  type    = string
  default = "10.0.1.0/24"
}
variable "pub_subnet_02_az" {
  type    = string
  default = "us-east-1b"
}
###################################
###################################