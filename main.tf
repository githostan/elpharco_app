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
}
