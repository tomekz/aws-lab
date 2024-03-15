# data "aws_partition" "current" {}
#
# data "aws_caller_identity" "current" {}
#
# data "aws_region" "current" {}
#
# data "aws_eks_cluster" "eks_cluster" {
#   name = var.eks_cluster_id
# }
#
# data "aws_eks_cluster_auth" "this" {
#   name = var.eks_cluster_id
# }

locals {
  # eks_cluster_endpoint = var.eks_cluster_endpoint
  # eks_oidc_issuer_url  = var.eks_oidc_issuer_url
  # addon_context = {
  #   aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
  #   aws_caller_identity_arn        = data.aws_caller_identity.current.arn
  #   aws_eks_cluster_endpoint       = "https://4EFCA3C5D85A1BBE0ABD6CC832E0A758.gr7.eu-central-1.eks.amazonaws.com"
  #   aws_partition_id               = data.aws_partition.current.partition
  #   aws_region_name                = data.aws_region.current.name
  #   eks_cluster_id                 = data.aws_eks_cluster.eks_cluster.id
  #   eks_oidc_issuer_url            = local.eks_oidc_issuer_url
  #   eks_oidc_provider_arn          = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_issuer_url}"
  #   tags                           = {}
  #   irsa_iam_role_path             = "/"
  #   irsa_iam_permissions_boundary  = ""
  # }

  #ec2
  hello        = "test msg"
  jumpbox_name = "lab-eks-jumpbox"
  cloud_init   = base64encode(templatefile("${path.module}/user-data/cloud_init.yaml.tpl", { hello = local.hello }))


  #vpc
  vpc_name = "lab-eks"
  vpc_cidr = "10.205.100.0/23"

  #eks
  clusters = {
    lab-eks = {
      mesh_id      = "labk-eks-mesh"
      trust_domain = "cluster.local"
    }
  }


}
