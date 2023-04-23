data "aws_region" "current_region" {}

data "aws_availability_zones" "available_zone" {}

data "aws_vpc" "created_vpc" {
    id = aws_vpc.internal.id
}