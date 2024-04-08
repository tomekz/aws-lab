environments:
%{ for cluster in clusters ~}
  ${cluster}:
    kubeContext: arn:aws:eks:${region}:${account}:cluster/${cluster}
    values:
    - ci/helm/values-${cluster}.yml
%{ endfor ~}

---
repositories:
- name: istio
  url: https://istio-release.storage.googleapis.com/charts

releases:
- name: base
  chart: istio/base
  version: ${istio_version}
  labels:
    component: base
  namespace: istio-system

- name: istiod
  chart: istio/istiod
  version: ${istio_version}
  labels:
    component: istiod
  namespace: istio-system
  values:
  - ci/helm/istiod.yml.gotmpl

- name: istio-cni
  chart: istio/cni
  version: ${istio_version}
  labels:
    component: istio-cni
  namespace: istio-system
  values:
  - ci/helm/istio-cni.yml.gotmpl

- name: istio-ingress
  chart: istio/gateway
  version: ${istio_version}
  labels:
    component: istio-ingress
  namespace: istio-system
  values:
  - ci/helm/istio-gateway.yml.gotmpl

- name: istio-egress
  chart: istio/gateway
  version: ${istio_version}
  labels:
    component: istio-egress
  namespace: istio-system
  values:
  - ci/helm/istio-gateway.yml.gotmpl
