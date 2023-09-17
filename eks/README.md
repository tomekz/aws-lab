# TODO
- [X] add https://eksctl.io/ to dev container
- [.] automate:
    - [X] create and destroy new eks cluster using eksctl
    - [ ] deploy argocd to eks cluster 
    - [ ] configure argo to deploy services from this repo


## eksctl

```bash
######################
# Creating a cluster #
######################

eksctl create cluster  --config-file eks/cluster.yaml 


##########################
# Exploring the outcomes #
##########################


eksctl get clusters --region eu-central-1

kubectl get nodes

#######################
# What else is there? #
#######################

eksctl utils describe-addon-versions \
    --cluster devops-catalog \
    --region us-east-2

##########################
# Destroying the cluster #
##########################

eksctl delete cluster  --config-file eks/cluster.yaml  --wait
```

## argo
