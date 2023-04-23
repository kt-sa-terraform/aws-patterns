output "cluster_name" {
  value = module.eks.cluster_name 
}

output "aws_auth_role_arn" {
  value = aws_iam_role.eks_role.arn
}

output "externaldns_role_arn" {
  value = aws_iam_role.eks_node.arn
}

output cluster_endpoint {
  value       = module.eks.cluster_endpoint
}

output cluster_certificate_authority_data {
  value       = module.eks.cluster_certificate_authority_data
}

output "eks_vpc_id" {
  value       = aws_vpc.eks.id
}

output "eks_public_subnet_id" {
  value = aws_subnet.eks_public_subnet[*].id
}


output "eks_private_subnet_id" {
  value = aws_subnet.eks_private_subnet[*].id
}

output eks_vpc_cidr {
  value       = data.aws_vpc.eks_created_vpc.cidr_block
}