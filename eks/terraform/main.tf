module "vpc" {

  source = "./modules/vpc"

  name     = local.vpc_name
  vpc_cidr = local.vpc_cidr

  clusters = keys(local.clusters)
}

module "ec2" {

  source = "./modules/ec2"

  name       = local.jumpbox_name
  ami_id     = data.aws_ami.this.id
  vpc_id     = module.vpc.vpc_id
  vpc_cidr   = module.vpc.vpc_cidr_block
  subnet_ids = module.vpc.private_subnets
  cloud_init = local.cloud_init
}
