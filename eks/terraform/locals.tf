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

  domain_name            = "sanguo.cn"
  alternate_domain_names = ["sangoku.jp"]

  #ec2
  hello        = "test msg"
  jumpbox_name = "lab-eks-jumpbox"
  # cloud_init   = base64encode(templatefile("${path.module}/user-data/cloud_init.yaml.tpl", { hello = local.hello }))


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

  istio_version = "1.20.3"

  # PKI files
  rootca_pkey = base64encode(file("${path.module}/rootca/root-cert-key.pem"))
  rootca      = base64encode(file("${path.module}/rootca/root-cert.pem"))
  intca_pkey  = base64encode(module.intca.private_key_pem)
  intca       = base64encode(module.intca.ca_cert_pem)

  # Istio configuration files
  istio_values_yml = { for k, v in local.clusters : k => base64encode(templatefile("${path.module}/user-data/values.yml.tpl", { mesh_id = v.mesh_id, cluster_name = k, vpc_name = local.vpc_name, trust_domain = v.trust_domain })) }
  helmfile         = base64encode(templatefile("${path.module}/user-data/helmfile.yaml.tpl", { istio_version = local.istio_version, clusters = keys(local.clusters), region = data.aws_region.current.name, account = data.aws_caller_identity.current.account_id }))

  # Cloud init base64-encoded files & scripts
  #bootstrap = base64encode(templatefile("${path.module}/user-data/bootstrap.sh.tpl", { clusters = join(" ", keys(local.clusters)), istio_version = local.istio_version }))
  #cloud_init = base64encode(templatefile("${path.module}/user-data/cloud_init.yml.tpl", { bootstrap_sh = local.bootstrap, istio_values_yml = local.istio_values_yml, helmfile = local.helmfile, rootca_pkey = local.rootca_pkey, rootca = local.rootca, intca_pkey = local.intca_pkey, intca = local.intca }))
  cloud_init = base64encode(templatefile("${path.module}/user-data/cloud_init.yml.tpl", { istio_values_yml = local.istio_values_yml, helmfile = local.helmfile, rootca_pkey = local.rootca_pkey, rootca = local.rootca, intca_pkey = local.intca_pkey, intca = local.intca }))
}
