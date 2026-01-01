
output "vpc_id" { 
    value = aws_vpc.arco_infra.id 
    }
#######################################################################################################################################################
#######################################################################################################################################################

# output "public_subnet_ids" {
#   value = [aws_subnet.arco_pub_subnet_01.id,aws_subnet.arco_pub_subnet_02.id]
# }

output "pub_subnet_01_id" {
    value = aws_subnet.arco_pub_subnet_01
}

output "pub_subnet_02_id" {
    value = aws_subnet.arco_pub_subnet_02
}

