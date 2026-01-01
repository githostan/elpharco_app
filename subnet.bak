### public subnet1 ########################################################
resource "aws_subnet" "elpharco-webtier-public-snet-01" {
  vpc_id     = aws_vpc.elpharco-webApp.id
  cidr_block = var.public_snet1-cidr
  map_public_ip_on_launch = true  # Enable auto-assigning public IPv4 addresses
  availability_zone       = var.public_snet1-az  # Specify the availability zone

  tags = {
    Name = "webtier-pub-snet-01"
  }
}

### public subnet2 ########################################################
resource "aws_subnet" "elpharco-webtier-public-snet-02" {
  vpc_id     = aws_vpc.elpharco-webApp.id
  cidr_block = var.public_snet2-cidr
  map_public_ip_on_launch = true  # Enable auto-assigning public IPv4 addresses
  availability_zone       = var.public_snet2-az  # Specify the availability zone

  tags = {
    Name = "webtier-pub-snet-02"
  }
}
###############################################################################################################################################################################
################################################################################################################################################################################

## private subnet1 ########################################################
resource "aws_subnet" "elpharco-apptier-private-snet-01" {
  vpc_id     = aws_vpc.elpharco-webApp.id
  cidr_block = var.private_snet1-cidr
  map_public_ip_on_launch = false  # Enable auto-assigning public IPv4 addresses
  availability_zone       = var.private_snet1-az  # Specify the availability zone

  tags = {
    Name = "apptier-prvt-snet-01"
  }
}

## private subnet2 ########################################################
resource "aws_subnet" "elpharco-apptier-private-snet-02" {
  vpc_id     = aws_vpc.elpharco-webApp.id
  cidr_block = var.private_snet2-cidr
  map_public_ip_on_launch = false  # Enable auto-assigning public IPv4 addresses
  availability_zone       = var.private_snet2-az  # Specify the availability zone

  tags = {
    Name = "elpharco-prvt-snet-02"
  }
}

###############################################################################################################################################################################
################################################################################################################################################################################

## private subnet3 ########################################################
resource "aws_subnet" "elpharco-dbtier-private-snet-03" {
  vpc_id     = aws_vpc.elpharco-webApp.id
  cidr_block = var.private_snet3-cidr
  map_public_ip_on_launch = false  # Enable auto-assigning public IPv4 addresses
  availability_zone       = var.private_snet3-az  # Specify the availability zone

  tags = {
    Name = "dbtier-prvt-snet-03"
  }
}

## private subnet4 ########################################################
resource "aws_subnet" "elpharco-dbtier-private-snet-04" {
  vpc_id     = aws_vpc.elpharco-webApp.id
  cidr_block = var.private_snet4-cidr
  map_public_ip_on_launch = false  # Enable auto-assigning public IPv4 addresses
  availability_zone       = var.private_snet4-az  # Specify the availability zone

  tags = {
    Name = "dbtier-prvt-snet-04"
  }
}

resource "aws_db_subnet_group" "elpharco-db-snet-grp" {
  name       = "db-snet-grp"
  subnet_ids = [aws_subnet.elpharco-dbtier-private-snet-03.id, aws_subnet.elpharco-dbtier-private-snet-04.id]

  tags = {
    Name = "elpharco-db-snet-grp"
  }
}



