
### Internet Gateway for the public subnets ###
resource "aws_internet_gateway" "elpharco-webApp-gw" {
  vpc_id = aws_vpc.elpharco-webApp.id

  tags = {
    Name = "elpharco-int-gw"
  }
}

### Route table for public subnets (web tier)- connecting to Internet Gateway ###
resource "aws_route_table" "elpharco-webtier-public-rtb" {
  vpc_id = aws_vpc.elpharco-webApp.id

  route {
    cidr_block        = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.elpharco-webApp-gw.id
  }

  tags = {
    Name = "elpharco_pub_rt"
  }
}

# Associate Route Table with Public Subnet1
resource "aws_route_table_association" "elpharco-webApp-public-snet-01-association" {
  subnet_id      = aws_subnet.elpharco-webtier-public-snet-01.id
  route_table_id = aws_route_table.elpharco-webtier-public-rtb.id
}
# Associate Route Table with Public Subnet2
resource "aws_route_table_association" "elpharco-webApp-public-snet-02-association" {
  subnet_id      = aws_subnet.elpharco-webtier-public-snet-02.id
  route_table_id = aws_route_table.elpharco-webtier-public-rtb.id
}








