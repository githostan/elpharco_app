
# The NAT instance must have internet access, So, it must be in a public subnet 
# (a subnet that has a route table with a route to the internet gateway), and it 
# must have a public IP address or an Elastic IP address.

## Elastic IP for nat-gateway #############
resource "aws_eip" "elpharco-natgw-eip" {
  domain = "vpc"
  #depends_on = [aws_internet_gateway.elpharco-webApp-gw]
  tags = {
    Name = "elpharco-eip-for-natgw"
  }
}      

# NAT gateway for app-tier private subnets [The nat gateway must be deployed in a public subnet] 
# NAT enables the private subnets to access the internet - eg. ec2 instances downloading softwares from internet, patches, or package updates etc
resource "aws_nat_gateway" "public-nat-gateway" {
  allocation_id                  = aws_eip.elpharco-natgw-eip.id
  subnet_id                      = aws_subnet.elpharco-webtier-public-snet-01.id
  depends_on = [aws_internet_gateway.elpharco-webApp-gw]

  tags = {
    Name = "natgw-for-prvt-snets"
  }
}

# Route table connecting to NAT gateway for private subnets (We can associate this table with all 4 private subnets)
resource "aws_route_table" "elpharco-apptier-dbtier-private-rtb" {
  vpc_id = aws_vpc.elpharco-webApp.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public-nat-gateway.id
  }
}

# Associate Route Table with private subnet1
resource "aws_route_table_association" "elpharco-private-snet-01-association" {
  subnet_id      = aws_subnet.elpharco-apptier-private-snet-01.id  # Replace with your private subnet IDs
  route_table_id = aws_route_table.elpharco-apptier-dbtier-private-rtb.id
}

# Associate Route Table with private subnet2
resource "aws_route_table_association" "elpharco-private-snet-02-association" {
  subnet_id      = aws_subnet.elpharco-apptier-private-snet-02.id  # Replace with your private subnet IDs
  route_table_id = aws_route_table.elpharco-apptier-dbtier-private-rtb.id
}

