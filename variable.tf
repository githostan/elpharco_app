
## variable region
variable "region" {
  type    = string
  default = "us-east-1"
}
###################################
###################################

## variable vpc
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
###################################
###################################

## variable public_subnet
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

## variable private_subnet
variable "prvt_subnet_01_cidr" {
  type    = string
  default = "10.0.2.0/24"
}
variable "prvt_subnet_01_az" {
  type    = string
  default = "us-east-1a"
}

variable "prvt_subnet_02_cidr" {
  type    = string
  default = "10.0.4.0/24"
}
variable "prvt_subnet_02_az" {
  type    = string
  default = "us-east-1b"
}
###################################
###################################

## variable db_subnet
variable "db_subnet_01_cidr" {
  type    = string
  default = "10.0.5.0/24"
}
variable "db_subnet_01_az" {
  type    = string
  default = "us-east-1a"
}

variable "db_subnet_02_cidr" {
  type    = string
  default = "10.0.6.0/24"
}
variable "db_subnet_02_az" {
  type    = string
  default = "us-east-1b"
}
###################################
###################################

## variable os, instance_type, key and userdata
variable "os_name" {
    type  = string
  default = "ami-02d7fd1c2af6eead0"
}

variable "instance_type" {
    type  = string
  default = "t2.micro"
}

variable "key_name" {
    type  = string
  default = "elpharco_keyPair"
}

variable "userdata_file" {
    type  = string
  
  default = "base_ami_config.sh"
}
###################################
###################################