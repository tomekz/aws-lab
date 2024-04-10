module "eks" {

  source  = "terraform-aws-modules/eks/aws"
  version = "20.4.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access

  enable_irsa = true

  cluster_enabled_log_types = ["audit"]

  vpc_id                   = var.vpc_id
  control_plane_subnet_ids = var.subnet_ids

  enable_cluster_creator_admin_permissions = true

  access_entries = {
    admin = {
      kubernetes_groups = []
      principal_arn     = var.cluster_admin_arn

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  cluster_security_group_additional_rules = {
    local = {
      cidr_blocks = [var.vpc_cidr]
      from_port   = 443
      to_port     = 443
      protocol    = "TCP"
      type        = "ingress"
      description = "(terraform) Inbound VPC TCP/443"
    }
  }
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({ enableNetworkPolicy = tostring(true) })

  depends_on = [module.node]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [module.node]
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    module.node,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.kube_proxy
  ]
}
