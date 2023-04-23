resource "aws_vpc" "internal" {
  cidr_block           = var.vpc_config.cidr_block
  enable_dns_hostnames = true

  tags = {
    "Name"   = var.vpc_config.vpc_name,
    "Shared" = "true",
    "Terraform" = "true"
  }
}

resource "aws_internet_gateway" "internal_vpc" {
  vpc_id = aws_vpc.internal.id

  tags = {
    "Name" = "${var.vpc_config.vpc_name}",
    "Terraform" = "true"
  }
}


resource "aws_subnet" "public_subnet" {
  count = length(data.aws_availability_zones.available_zone.names)

  availability_zone = data.aws_availability_zones.available_zone.names[count.index]
  cidr_block        = cidrsubnet(var.vpc_config.cidr_block, var.vpc_config.subnet_bits, length(data.aws_availability_zones.available_zone.names) + tonumber(count.index))
  vpc_id            = aws_vpc.internal.id

  tags = {
    "Name"                                      = "[Public] ${var.vpc_config.vpc_name} ${data.aws_availability_zones.available_zone.names[count.index]}",
    "shared" = "true",
    "Tier"                                      = "public",
    "Terraform" = "true"
  }
}


resource "aws_route_table" "public_table" {
  vpc_id = aws_vpc.internal.id
  tags = {
    "Name" = "[Public_table]${var.vpc_config.vpc_name}",
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internal_vpc.id

  depends_on = [
    aws_route_table.public_table
  ]
}


resource "aws_route_table_association" "public_route" {
  count = length(aws_subnet.public_subnet)

  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.public_table.id
}

resource "aws_subnet" "private_subnet" {
  count = length(data.aws_availability_zones.available_zone.names)

  availability_zone = data.aws_availability_zones.available_zone.names[count.index]
  cidr_block        = cidrsubnet(var.vpc_config.cidr_block, var.vpc_config.subnet_bits, count.index)
  vpc_id            = aws_vpc.internal.id

  tags = {
    "Name"                                      = "[Private] ${var.vpc_config.vpc_name} ${data.aws_availability_zones.available_zone.names[count.index]}",
    "Shared" = "true",
    "Tier"                                      = "private"
    "Terraform" = "true"
  }
  depends_on = [
    aws_subnet.public_subnet,
  ]
}

resource "aws_eip" "vpc_natgw_ip" {
  count = length(aws_subnet.private_subnet)
  vpc   = true
  tags = {
    "Name"               = "[NAT] ${var.vpc_config.vpc_name} ${aws_subnet.private_subnet[count.index].availability_zone}",
    "availability-zones" = aws_subnet.private_subnet[count.index].availability_zone
  }
}

resource "aws_nat_gateway" "vpc_natgw" {
  count         = length(aws_subnet.public_subnet)
  allocation_id = aws_eip.vpc_natgw_ip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    "Name"               = "${var.vpc_config.vpc_name} ${aws_subnet.public_subnet[count.index].availability_zone}",
    "availability-zones" = aws_subnet.private_subnet[count.index].availability_zone
  }
  depends_on = [
    aws_subnet.private_subnet,
    aws_eip.vpc_natgw_ip
  ]
}

resource "aws_route_table" "private_table" {
  count  = length(aws_subnet.private_subnet)
  vpc_id = aws_vpc.internal.id

  tags = {
    "Name"               = "${var.vpc_config.vpc_name} ${aws_subnet.private_subnet[count.index].availability_zone}",
    "availability-zones" = aws_subnet.private_subnet[count.index].availability_zone
  }
}

resource "aws_route" "private_route" {
  count                  = length(aws_subnet.private_subnet)
  route_table_id         = aws_route_table.private_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc_natgw[count.index].id

  depends_on = [
    aws_route_table.private_table
  ]
}

resource "aws_route_table_association" "private_route" {
  count = length(aws_subnet.private_subnet)

  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_table[count.index].id


  depends_on = [
    aws_route_table.private_table,
    aws_subnet.private_subnet
  ]

}
