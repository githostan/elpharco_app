
## variable region
variable "region" {
  type    = string
}
###################################
###################################

## variable vpc
variable "vpc_cidr" {
  type    = string
}
###################################
###################################

## variable public_subnet
variable "pub_subnet_01_cidr" {
  type    = string
}
variable "pub_subnet_01_az" {
  type    = string
}
variable "pub_subnet_02_cidr" {
  type    = string
}
variable "pub_subnet_02_az" {
  type    = string
}
###################################
###################################

## variable private_subnet
variable "prvt_subnet_01_cidr" {
    type  = string
}
variable "prvt_subnet_01_az" {
    type  = string
}

variable "prvt_subnet_02_cidr" {
    type  = string
}
variable "prvt_subnet_02_az" {
    type  = string
}