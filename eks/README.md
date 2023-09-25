# TODO
- [X] add https://eksctl.io/ to dev container
- [.] automate:
    - [X] create and destroy new eks cluster using eksctl
    - [ ] deploy argocd to eks cluster (see the eks workshop https://www.eksworkshop.com/docs/automation/gitops/)
    - [ ] configure argo to deploy services from this repo


## eksctl

######################
# Creating a cluster #
######################

1. `eksctl create cluster  --config-file eks/cluster.yaml`
2. configure cluster RBAC for aws user
```
kubectl edit configmap aws-auth -n kube-system
```
Then go down to mapUsers and add the following (replace [account_id] with your Account ID)
```
mapUsers: |
  - userarn: arn:aws:iam::[account_id]:root
    groups:
    - system:masters
```

or use eksctl


```
 eksctl create iamidentitymapping --cluster lab --region=eu-central-1 --arn arn:aws:iam::[account_id]:user/terraform_user --group system:masters --username admin

```

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
