output "vpc_id" {
  value = aws_vpc.internal.id
}

output "internet_gw_id" {
  value = aws_internet_gateway.internal_vpc.id
}

output "aws_public_subnet_id" {
  value = aws_subnet.public_subnet[*].id
}


output "aws_private_subnet_id" {
  value = aws_subnet.private_subnet[*].id
}

output "natgw_ip" {
  value = aws_eip.vpc_natgw_ip[*].public_ip
}

output vpc_cidr {
  value       = data.aws_vpc.created_vpc.cidr_block
}

