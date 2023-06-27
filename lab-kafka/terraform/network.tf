resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = local.tags
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = local.tags
}

#Get all available AZ's in VPC
data "aws_availability_zones" "azs" {
  state = "available"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id
  tags          = local.tags
}

resource "aws_eip" "nat" {
  vpc = true
  tags = local.tags
}

resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  map_public_ip_on_launch = true
  cidr_block        = "10.0.1.0/24"
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  tags              = merge(local.tags, { "Name" = "aws-lab-kafka-public-1" })
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  map_public_ip_on_launch = true
  cidr_block        = "10.0.2.0/24"
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  tags              = merge(local.tags, { "Name" = "aws-lab-kafka-private-1" })
}

resource "aws_route_table" "internet_route" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = local.tags
}

# Update the route table for the private subnet to use the NAT gateway
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route_table_association" "set-master-default-rt-assoc" {
  subnet_id         = aws_subnet.public_1.id
  route_table_id = aws_route_table.internet_route.id
}

