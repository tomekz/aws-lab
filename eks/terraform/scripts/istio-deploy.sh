#!/bin/bash

# NOTE: This script shouldn't be executed until Terraform provisions the entire infrastructure.
# It is meant to be executed in the EC2 jumphost.
#
# Usage: istio_deploy.sh <CLUSTER_NAME>
#
helm plugin add https://github.com/databus23/helm-diff

set -o xtrace

kubectl config use-context arn:aws:eks:eu-central-1:925303156481:cluster/$1

# Create istio-system namespace
kubectl create ns istio-system || true

# Create a Kubernetes secret with Intermediate CA TLS certificate and key, Root CA TLS certificate and TLS certificate bundle 
kubectl create secret generic cacerts -n istio-system --from-file=ca-cert.pem --from-file=ca-key.pem --from-file=root-cert.pem --from-file=cert-chain.pem

# Apply Helmfile
helmfile -e $1 apply

set +o xtrace
