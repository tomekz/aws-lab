resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = local.tags
}

resource "aws_internet_gateway" "igw" {
  vpc_id   = aws_vpc.main.id
  tags = local.tags
}

#Get all available AZ's in VPC
data "aws_availability_zones" "azs" {
  state    = "available"
}

resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  tags = local.tags
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  tags = local.tags
}

resource "aws_route_table" "internet_route" {
  vpc_id   = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = local.tags
}

resource "aws_main_route_table_association" "set-master-default-rt-assoc" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.internet_route.id
}
