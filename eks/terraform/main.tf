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

module "intca" {
  source = "./modules/intca"

  domain_name            = local.domain_name
  alternate_domain_names = local.alternate_domain_names
  ca_private_key         = base64decode(local.rootca_pkey)
  ca_cert                = base64decode(local.rootca)
}

module "eks" {
  source = "./modules/eks"

  cluster_name                   = local.clusters["lab-eks"].name
  vpc_id                         = module.vpc.vpc_id
  vpc_cidr                       = module.vpc.vpc_cidr_block
  subnet_ids                     = module.vpc.private_subnets
  cluster_admin_arn              = module.ec2.ec2_instance_role_arn
  cluster_endpoint_public_access = false
}
