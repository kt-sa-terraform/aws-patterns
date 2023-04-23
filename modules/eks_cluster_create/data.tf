data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_vpc" "eks_created_vpc" {
    id = aws_vpc.eks.id
}