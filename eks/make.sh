#!/bin/bash

cluster-create() {
    echo "Hello, world!"
}

cluster-delete() {
    echo "Goodbye, world!"
}

if [ "$1" == "cluster-create" ]; then
    cluster-create
elif [ "$1" == "cluster-delete" ]; then
    cluster-delete
else
    echo "Usage: $0 {cluster-create|cluster-delete}"
fi
