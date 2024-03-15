module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.2"

  name = var.name
  cidr = var.vpc_cidr

  azs = [
    "eu-west-1a",
    "eu-west-1b",
  ]

  private_subnets = [
    cidrsubnet(var.vpc_cidr, 2, 0),
    cidrsubnet(var.vpc_cidr, 2, 1),
  ]

  public_subnets = [
    cidrsubnet(var.vpc_cidr, 2, 2),
    cidrsubnet(var.vpc_cidr, 2, 3)
  ]

  private_subnet_names = [
    "${var.name}-private-0",
    "${var.name}-private-1",
  ]

  public_subnet_names = [
    "${var.name}-public-0",
    "${var.name}-public-1",
  ]

  manage_default_network_acl    = true
  manage_default_security_group = true
  enable_dns_hostnames          = true
  enable_dns_support            = true
  enable_nat_gateway            = true
  single_nat_gateway            = true
  one_nat_gateway_per_az        = false

  private_subnet_tags = merge({
    SubnetType                                  = "private"
    "kubernetes.io/role/internal-alb"           = "1"
  }, local.cluster_subnet_tags
  )

  private_route_table_tags = {
    SubnetType = "private"
  }

  public_subnet_tags = {
    SubnetType = "public"
  }

  public_route_table_tags = {
    SubnetType = "public"
  }
}
