
### VPC #################################################################
resource "aws_vpc" "arco_infra" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "arco_vpc"
  }
}