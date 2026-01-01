
### VPC #################################################################
resource "aws_vpc" "arco_infra" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "arco_vpc"
  }
}

### public subnet1 ########################################################
resource "aws_subnet" "arco_pub_subnet_01" {
  vpc_id     = aws_vpc.arco_infra.id
  cidr_block = var.pub_subnet_01_cidr
  map_public_ip_on_launch = true  # Enable auto-assigning public IPv4 addresses
  availability_zone       = var.pub_subnet_01_az  # Specify the availability zone

  tags = {
    Name = "pub_subnet_01"
  }
}

### public subnet2 ########################################################
resource "aws_subnet" "arco_pub_subnet_02" {
  vpc_id     = aws_vpc.arco_infra.id
  cidr_block = var.pub_subnet_02_cidr
  map_public_ip_on_launch = true  # Enable auto-assigning public IPv4 addresses
  availability_zone       = var.pub_subnet_02_az  # Specify the availability zone

  tags = {
    Name = "pub_subnet_02"
  }
}
###############################################################################################################################################################################
################################################################################################################################################################################