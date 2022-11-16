# ID VPC
output "vpc_id" {
  value = aws_vpc.my-vpc.id
}

#ID Internet Gateway
output "igw_id"{
  value = aws_internet_gateway.gw.id
}
