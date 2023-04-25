resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = merge(local.tags, { "Name" = "aws-lab-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, { "Name" = "aws-lab-igw" })
}

#Get all available AZ's in VPC
data "aws_availability_zones" "azs" {
  state = "available"
}

resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  map_public_ip_on_launch = true
  cidr_block        = "10.0.1.0/24"
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  tags              = merge(local.tags, { "Name" = "aws-lab-public-1" })
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  map_public_ip_on_launch = true
  cidr_block        = "10.0.2.0/24"
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  tags              = merge(local.tags, { "Name" = "aws-lab-public-2" })
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
  tags = merge(local.tags, { "Name" = "aws-lab-rt" })
}

resource "aws_main_route_table_association" "set-master-default-rt-assoc" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.internet_route.id
}

#Create SG for Load Balancer, only TCP/80,TCP/443 and outbound access
resource "aws_security_group" "lb-sg" {
  name        = "lb-sg"
  description = "Allow 443 and traffic to Jenkins SG"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "Allow 443 from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow 80 from anywhere for redirection"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create SG for allowing TCP/8080 from * and TCP/22 from your IP
resource "aws_security_group" "jenkins-sg" {
  name        = "jenkins-sg"
  description = "Allow TCP/8080 & TCP/22"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "Allow 22 from our public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description     = "allow anyone on port 8080"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.lb-sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
