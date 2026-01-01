# Provider
provider "aws" {
  region  = var.region
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

  region    = var.region
  vpc_cidr  = var.vpc_cidr
  pub_subnet_01_cidr = var.pub_subnet_01_cidr
  pub_subnet_01_az   = var.pub_subnet_01_az
  pub_subnet_02_cidr = var.pub_subnet_02_cidr
  pub_subnet_02_az   = var.pub_subnet_02_az
}
