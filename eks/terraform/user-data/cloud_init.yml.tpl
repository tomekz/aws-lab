#cloud-config

packages:
  - git

write_files:
%{ for k, v in istio_values_yml ~}
  - encoding: b64
    path: /home/ssm-user/ci/helm/values-${k}.yml
    content: ${v}
    permissions: '0644'
%{ endfor ~}

  - encoding: b64
    path: /home/ssm-user/helmfile.yaml
    content: ${helmfile}
    permissions: '0644'

  - encoding: b64
    path: /home/ssm-user/ca-key.pem
    content: ${intca_pkey}
    permissions: '0400'

  - encoding: b64
    path: /home/ssm-user/ca-cert.pem
    content: ${intca}
    permissions: '0644'

