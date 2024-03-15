locals {
  cluster_subnet_tags = { for cluster in var.clusters : "kubernetes.io/cluster/${cluster}" => "shared" }
}
