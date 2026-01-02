
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
resource "aws_subnet" "arco_prvt_subnet_02" {
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
###############################################################################################################################################################################
###############################################################################################################################################################################
# Route tables control how traffic flows within the VPC. while public subnets route 0.0.0.0/0 to the internet gateway 
# for direct internet access, private subnets route 0.0.0.0/0 to the nat gateway so instances can reach the internet 
# securely without being publicly exposed.
###############################################################################################################################################################################

## public route table directing outbound traffic from web-tier subnets to the internet gateway for public internet access.
resource "aws_route_table" "arco_pub_rtb" {
  vpc_id = aws_vpc.arco_infra.id

  route {
    cidr_block        = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.arco_intgw.id
  }

  tags = {
    Name = "arco_pub_rtb_web"
  }
}

## associates the pub route table with pub_subnet_01 so it uses the Intgw for outbound traffic.
resource "aws_route_table_association" "arco_pub_subnet_01_assoc" {
  subnet_id      = aws_subnet.arco_pub_subnet_01.id
  route_table_id = aws_route_table.arco_pub_rtb.id
}
## associates the pub route table with pub_subnet_02 so it uses the Intgw for outbound traffic.
resource "aws_route_table_association" "arco_pub_subnet_02_assoc" {
  subnet_id      = aws_subnet.arco_pub_subnet_02.id
  route_table_id = aws_route_table.arco_pub_rtb.id
}
#######################################################################################################################################################
#######################################################################################################################################################

# route table connecting to nat gateway for private subnets (can be associated with all prvt app/db subnets)
resource "aws_route_table" "arco_prvt_rtb" {
  vpc_id = aws_vpc.arco_infra.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.arco_natgw.id
  }

  tags = {
    Name = "arco_prvt_rtb_app"
  }
}

# associates the prvt route table with prvt_subnet_01 so it uses the natgw for secure outbound internet access.
resource "aws_route_table_association" "arco_prvt_subnet_01_assoc" {
  subnet_id      = aws_subnet.arco_prvt_subnet_01.id  # replace with your private subnet ids
  route_table_id = aws_route_table.arco_prvt_rtb.id
}

# associates the prvt route table with prvt_subnet_02 so it uses the natgw for secure outbound internet access.
resource "aws_route_table_association" "arco_prvt_subnet_02_assoc" {
  subnet_id      = aws_subnet.arco_prvt_subnet_02.id  # replace with your private subnet ids
  route_table_id = aws_route_table.arco_prvt_rtb.id
}








