#!/bin/bash

# NOTE: This script shouldn't be executed until Terraform provisions the entire infrastructure.
# It is meant to be executed in the EC2 jumphost.
#
# Usage: istio_deploy.sh <CLUSTER_NAME>
#
helm plugin add https://github.com/databus23/helm-diff

AWS_REGION="eu-west-1"
AWS_ACCOUNT="082816727974"

set -o xtrace

# kubectl config use-context arn:aws:eks:eu-west-1:082816727974:cluster/bp-mesh-tz
kubectl config use-context arn:aws:eks:eu-west-1:082816727974:cluster/$1

# Create istio-system namespace
kubectl create ns istio-system || true

# rename CA files - don't ask, but this is required
mv -f ca-cert-$1.pem ca-cert.pem
mv -f ca-key-$1.pem ca-key.pem
mv -f cert-chain-$1.pem cert-chain.pem

# Create a Kubernetes secret with Intermediate CA TLS certificate and key, Root CA TLS certificate and TLS certificate bundle 
kubectl create secret generic cacerts -n istio-system --from-file=ca-cert.pem --from-file=ca-key.pem --from-file=root-cert.pem --from-file=cert-chain.pem

# Apply Helmfile
helmfile -e $1 apply

set +o xtrace
