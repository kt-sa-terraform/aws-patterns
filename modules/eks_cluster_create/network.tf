resource "aws_vpc" "eks" {
  cidr_block           = var.vpc_config.cidr_block
  enable_dns_hostnames = true

  tags = {
    "Name"   = var.cluster_name,
    "Shared" = "true"
  }
}

resource "aws_internet_gateway" "eks_vpc" {
  vpc_id = aws_vpc.eks.id

  tags = {
    "Name" = "${var.cluster_name}",
  }
}


resource "aws_subnet" "eks_public_subnet" {
  count = length(data.aws_availability_zones.available.names)

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.vpc_config.cidr_block, var.vpc_config.subnet_bits, length(data.aws_availability_zones.available.names) + tonumber(count.index))
  vpc_id            = aws_vpc.eks.id

  tags = {
    "Name"                                      = "[Public] ${var.cluster_name} ${data.aws_availability_zones.available.names[count.index]}",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
    "availability-zone"                         = data.aws_availability_zones.available.names[count.index],
    "Tier"                                      = "public"
  }
}


resource "aws_route_table" "eks_public_table" {
  vpc_id = aws_vpc.eks.id
  tags = {
    "Name" = var.cluster_name,
  }
}

resource "aws_route" "eks_public_route" {
  route_table_id         = aws_route_table.eks_public_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks_vpc.id

  depends_on = [
    aws_route_table.eks_public_table
  ]
}


resource "aws_route_table_association" "eks_public" {
  count = length(aws_subnet.eks_public_subnet)

  subnet_id      = aws_subnet.eks_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.eks_public_table.id
}

resource "aws_subnet" "eks_private_subnet" {
  count = length(data.aws_availability_zones.available.names)

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.vpc_config.cidr_block, var.vpc_config.subnet_bits, count.index)
  vpc_id            = aws_vpc.eks.id

  tags = {
    "Name"                                      = "[Private] ${var.cluster_name} ${data.aws_availability_zones.available.names[count.index]}",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
    "availability-zone"                         = data.aws_availability_zones.available.names[count.index],
    "Tier"                                      = "private"
  }
  depends_on = [
    aws_subnet.eks_public_subnet,
  ]
}

resource "aws_eip" "eks_natgw_ip" {
  count = length(aws_subnet.eks_private_subnet)
  vpc   = true
  tags = {
    "Name"               = "[NAT] ${var.cluster_name} ${aws_subnet.eks_private_subnet[count.index].availability_zone}",
    "availability-zones" = aws_subnet.eks_private_subnet[count.index].availability_zone
  }
}

resource "aws_nat_gateway" "eks_natgw" {
  count         = length(aws_subnet.eks_public_subnet)
  allocation_id = aws_eip.eks_natgw_ip[count.index].id
  subnet_id     = aws_subnet.eks_public_subnet[count.index].id

  tags = {
    "Name"               = "${var.cluster_name} ${aws_subnet.eks_public_subnet[count.index].availability_zone}",
    "availability-zones" = aws_subnet.eks_private_subnet[count.index].availability_zone
  }
  depends_on = [
    aws_subnet.eks_public_subnet,
    aws_eip.eks_natgw_ip
  ]
}

resource "aws_route_table" "eks_private_table" {
  count  = length(aws_subnet.eks_private_subnet)
  vpc_id = aws_vpc.eks.id

  tags = {
    "Name"               = "${var.cluster_name} ${aws_subnet.eks_private_subnet[count.index].availability_zone}",
    "availability-zones" = aws_subnet.eks_private_subnet[count.index].availability_zone
  }
}

resource "aws_route" "eks_private_route" {
  count                  = length(aws_subnet.eks_private_subnet)
  route_table_id         = aws_route_table.eks_private_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.eks_natgw[count.index].id

  depends_on = [
    aws_route_table.eks_private_table
  ]
}

resource "aws_route_table_association" "eks_private" {
  count = length(aws_subnet.eks_private_subnet)

  subnet_id      = aws_subnet.eks_private_subnet[count.index].id
  route_table_id = aws_route_table.eks_private_table[count.index].id


  depends_on = [
    aws_route_table.eks_private_table,
    aws_subnet.eks_private_subnet
  ]

}

