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
```
 eksctl create iamidentitymapping --cluster lab --region=eu-central-1 --arn arn:aws:iam::[account_id]:user --group system:masters --username admin

```
3. deploy k8s dashboard

```
export DASHBOARD_VERSION="v2.6.0"

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/${DASHBOARD_VERSION}/aio/deploy/recommended.yaml

```

run proxy
```
kubectl proxy --port=8080 --address=0.0.0.0 --disable-filter=true &

```
get token
```
aws eks get-token --cluster-name lab | jq -r '.status.token'

```

- http://localhost:8080/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login

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
