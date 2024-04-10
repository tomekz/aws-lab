#!/bin/env bash

# USAGE: bootstrap.sh <CLUSTER>

set -o xtrace

PLATFORM=$(uname -s)_amd64
EKS_CLUSTER="$@"
ISTIO_VERSION="1.20.3"

# install kubectl
curl -s -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.0/2024-01-04/bin/linux/amd64/kubectl
curl -s -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.0/2024-01-04/bin/linux/amd64/kubectl.sha256
sha256sum -c kubectl.sha256
rm -rf kubectl.sha256
chmod +x ./kubectl
mv kubectl /usr/local/bin/kubectl
kubectl version --client=true

# install eksctl
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm -rf eksctl_$PLATFORM.tar.gz
mv /tmp/eksctl /usr/local/bin/eksctl
eksctl version

# install helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
helm version --short
helm plugin add https://github.com/databus23/helm-diff
rm -rf ./get_helm.sh

# install helmfile
curl -LO https://github.com/helmfile/helmfile/releases/download/v0.162.0/helmfile_0.162.0_linux_amd64.tar.gz
tar -xzf helmfile_0.162.0_linux_amd64.tar.gz -C /tmp && rm -rf helmfile_0.162.0_linux_amd64.tar.gz
mv /tmp/helmfile /usr/local/bin/helmfile
helmfile version

# install istioctl
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION sh -
mv istio-$ISTIO_VERSION/bin/istioctl /usr/local/bin/istioctl
rm -rf istio-$ISTIO_VERSION/

# create and verify TLS certificate bundles
cat /home/ssm-user/ca-cert.pem /home/ssm-user/root-cert.pem > /home/ssm-user/cert-chain.pem
openssl verify -CAfile /home/ssm-user/root-cert.pem /home/ssm-user/cert-chain.pem
openssl x509 -in /home/ssm-user/ca-cert.pem -noout -text
aws eks update-kubeconfig --name $EKS_CLUSTER --region $AWS_REGION

# chown -R ssm-user:ssm-user /home/ssm-user

set +o xtrace
