locals {
  domain_name            = "sanguo.cn"
  alternate_domain_names = ["sangoku.jp"]

  #ec2
  hello        = "test msg"
  jumpbox_name = "lab-eks-jumpbox"


  #vpc
  vpc_name = "lab-eks"
  vpc_cidr = "10.205.100.0/23"

  #eks
  clusters = {
    lab-eks = {
      mesh_id      = "labk-eks-mesh"
      trust_domain = "cluster.local"
      name         = "lab-eks"
    }
  }

  istio_version = "1.20.3"

  # PKI files
  rootca_pkey = base64encode(file("${path.module}/rootca/root-cert-key.pem"))
  rootca      = base64encode(file("${path.module}/rootca/root-cert.pem"))
  intca_pkey  = base64encode(module.intca.private_key_pem)
  intca       = base64encode(module.intca.ca_cert_pem)

  # Istio configuration files
  istio_values_yml          = { for k, v in local.clusters : k => base64encode(templatefile("${path.module}/user-data/values.yml.tpl", { mesh_id = v.mesh_id, cluster_name = k, vpc_name = local.vpc_name, trust_domain = v.trust_domain })) }
  istiod_values_yaml        = base64encode(templatefile("${path.module}/ci/helm/istiod.yml.gotmpl", {}))
  istio_gateway_values_yaml = base64encode(templatefile("${path.module}/ci/helm/istio-gateway.yml.gotmpl", {}))
  istio_cni_values_yaml     = base64encode(templatefile("${path.module}/ci/helm/istio-cni.yml.gotmpl", {}))
  helmfile                  = base64encode(templatefile("${path.module}/user-data/helmfile.yaml.tpl", { istio_version = local.istio_version, clusters = keys(local.clusters), region = data.aws_region.current.name, account = data.aws_caller_identity.current.account_id }))

  # Cloud init base64-encoded files & scripts
  #bootstrap = base64encode(templatefile("${path.module}/user-data/bootstrap.sh.tpl", { clusters = join(" ", keys(local.clusters)), istio_version = local.istio_version }))
  #cloud_init = base64encode(templatefile("${path.module}/user-data/cloud_init.yml.tpl", { bootstrap_sh = local.bootstrap, istio_values_yml = local.istio_values_yml, helmfile = local.helmfile, rootca_pkey = local.rootca_pkey, rootca = local.rootca, intca_pkey = local.intca_pkey, intca = local.intca }))
  cloud_init = base64encode(templatefile("${path.module}/user-data/cloud_init.yml.tpl", { istio_cni_values_yaml = local.istio_cni_values_yaml, istio_gateway_values_yaml = local.istio_gateway_values_yaml, istiod_values_yaml = local.istiod_values_yaml, istio_values_yml = local.istio_values_yml, helmfile = local.helmfile, rootca_pkey = local.rootca_pkey, rootca = local.rootca, intca_pkey = local.intca_pkey, intca = local.intca }))
}
