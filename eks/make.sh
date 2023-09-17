#!/bin/bash

cluster-create() {
    eksctl create cluster  --config-file cluster.yaml 
}

cluster-delete() {
    eksctl delete cluster  --config-file cluster.yaml  --wait
}

if [ "$1" == "cluster-create" ]; then
    cluster-create
elif [ "$1" == "cluster-delete" ]; then
    cluster-delete
else
    echo "Usage: $0 {cluster-create|cluster-delete}"
fi
