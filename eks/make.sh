#!/bin/bash

CLUSTER_NAME=lab
AWS_REGION=eu-central-1

cluster-create() {
    eksctl create cluster  --config-file cluster.yaml 
}

cluster-delete() {
    eksctl delete cluster  --config-file cluster.yaml  --wait
}

write-kubeconfig() {
    aws eks --region $AWS_REGION update-kubeconfig --name $CLUSTER_NAME
}

if [ "$1" == "cluster-create" ]; then
    cluster-create
elif [ "$1" == "cluster-delete" ]; then
    cluster-delete
elif [ "$1" == "write-kubeconfig" ]; then
    write-kubeconfig
else
    echo "Usage: $0 {cluster-create|cluster-delete|write-kubeconfig}"
fi
