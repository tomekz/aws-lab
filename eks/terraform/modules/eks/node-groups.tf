module "node" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "20.4.0"

  name            = "${var.cluster_name}-mngrp"
  cluster_name    = module.eks.cluster_name
  cluster_version = module.eks.cluster_version

  bootstrap_extra_args = "--kubelet-extra-args \"--node-labels=node.kubernetes.io/lifecycle=normal\""

  subnet_ids     = var.subnet_ids
  instance_types = ["t3.medium"]
  capacity_type  = "ON_DEMAND"
  min_size       = 1
  max_size       = 3
  desired_size   = 2

  create_iam_role            = true
  iam_role_attach_cni_policy = true
  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids            = [module.eks.node_security_group_id]
}
