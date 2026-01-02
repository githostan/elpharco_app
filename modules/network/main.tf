
# the vpc provides an isolated, customizable network environment that hosts all tiers of the application securely.

### vpc #################################################################
resource "aws_vpc" "arco_infra" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "arco_vpc"
  }
}

###############################################################################################################################################################################
###############################################################################################################################################################################

# public subnets allow resources to have direct internet access through the internet gateway.

### public subnet_01 ########################################################
resource "aws_subnet" "arco_pub_subnet_01" {
  vpc_id     = aws_vpc.arco_infra.id
  cidr_block = var.pub_subnet_01_cidr
  map_public_ip_on_launch = true  # enable auto-assigning public ipv4 addresses
  availability_zone       = var.pub_subnet_01_az  # Specify the availability zone

  tags = {
    Name = "arco_pub_subnet_01"
  }
}

### public subnet_02 ########################################################
resource "aws_subnet" "arco_pub_subnet_02" {
  vpc_id     = aws_vpc.arco_infra.id
  cidr_block = var.pub_subnet_02_cidr
  map_public_ip_on_launch = true  # enable auto-assigning public ipv4 addresses
  availability_zone       = var.pub_subnet_02_az  # specify the availability zone

  tags = {
    Name = "arco_pub_subnet_02"
  }
}
###############################################################################################################################################################################
###############################################################################################################################################################################

# private subnets isolate app and db resources from the public internet while still allowing outbound access 
# via the nat gateway.

## private subnet_01 ########################################################
resource "aws_subnet" "arco_prvt_subnet_01" {
  vpc_id     = aws_vpc.arco_infra.id
  cidr_block = var.prvt_subnet_01_cidr
  map_public_ip_on_launch = false  # enable auto-assigning public ipv4 addresses
  availability_zone       = var.prvt_subnet_01_az # specify the availability zone

  tags = {
    Name = "arco_prvt_subnet_01"
  }
}

## private subnet_02 ########################################################
resource "aws_subnet" "arco_app_prvt_subnet_02" {
  vpc_id     = aws_vpc.arco_infra.id
  cidr_block = var.prvt_subnet_02_cidr
  map_public_ip_on_launch = false  # enable auto-assigning public ipv4 addresses
  availability_zone       = var.prvt_subnet_02_az   # specify the availability zone

  tags = {
    Name = "arco_prvt_subnet_02"
  }
}

###############################################################################################################################################################################
###############################################################################################################################################################################

# internet gateway provides the vpc with a path to the public internet, enabling public subnets and the nat gateway 
# to send outbound traffic.

### internet gateway for the public subnets ###
resource "aws_internet_gateway" "arco_intgw" {
  vpc_id = aws_vpc.arco_infra.id

  tags = {
    Name = "arco_intgw" 
  }
}

###############################################################################################################################################################################
###############################################################################################################################################################################

# elastic ip provides a fixed, public ipv4 address that the nat Gateway uses for all outbound internet traffic.
# the nat gateway must have a public or elastic ip to reach the internet through the internet gateway.
# Creating this eip ensures the nat gateway has a stable, routable address so private‑subnet
# resources (app/db tiers) can access the internet securely without being exposed.

## elastic ip for nat-gateway #############
resource "aws_eip" "arco_eip" {
  domain = "vpc"
  #depends_on = [aws_internet_gateway.arco_ingw]
  tags = {
    Name = "arco_eip"
  }
}      

###############################################################################################################################################################################
###############################################################################################################################################################################

# nat gateway allows instances in private subnets (app & db tiers) to access the internet for updates, patches,
# downloading software, and external dependencies, while preventing inbound internet traffic from reaching them. 
# it must be placed in a public subnet so it can route traffic through the internet gateway using its elastic ip.

resource "aws_nat_gateway" "arco_natgw" {
  allocation_id                  = aws_eip.arco_eip.id
  subnet_id                      = aws_subnet.arco_pub_subnet_01.id
  depends_on = [aws_internet_gateway.arco_intgw]

  tags = {
    Name = "arco_natgw"
  }
}