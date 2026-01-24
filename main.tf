# Provider
provider "aws" {
  region = var.region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.41.0"
    }
  }
}


module "network" {
  source = "./modules/network"

  region              = var.region
  vpc_cidr            = var.vpc_cidr
  pub_subnet_01_cidr  = var.pub_subnet_01_cidr
  pub_subnet_01_az    = var.pub_subnet_01_az
  pub_subnet_02_cidr  = var.pub_subnet_02_cidr
  pub_subnet_02_az    = var.pub_subnet_02_az
  prvt_subnet_01_cidr = var.prvt_subnet_01_cidr
  prvt_subnet_01_az   = var.prvt_subnet_01_az
  prvt_subnet_02_cidr = var.prvt_subnet_02_cidr
  prvt_subnet_02_az   = var.prvt_subnet_02_az
  db_subnet_01_cidr   = var.db_subnet_01_cidr
  db_subnet_01_az     = var.db_subnet_01_az
  db_subnet_02_cidr   = var.db_subnet_02_cidr
  db_subnet_02_az     = var.db_subnet_02_az
}

module "web" {
  source = "./modules/web"

  # from network-module
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids

  # from the web config
  os_name          = var.os_name
  instance_type    = var.instance_type
  key_name         = var.key_name
  userdata_file = var.userdata_file
}

