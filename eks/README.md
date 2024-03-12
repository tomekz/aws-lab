# TODO
- [X] add https://eksctl.io/ to dev container
- [.] automate:
    - [X] create and destroy new eks cluster using eksctl
    - [ ] deploy argocd to eks cluster (see the eks workshop https://www.eksworkshop.com/docs/automation/gitops/)
    - [ ] deploy istio to eks cluster
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
apiVersion: v1
data:
  mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::[account_id]:role/eksctl-lab-nodegroup-primary-1-18-NodeInstanceRole-1X19WXO7U3UM9
      username: system:node:{{EC2PrivateDNSName}}
  mapUsers: |
    - groups:
      - system:masters
      userarn: arn:aws:iam::[account_id]:user/terraform_user
      username: admin
    - groups:
      - system:masters
      userarn: arn:aws:iam::[account_id]:root
      username: admin
kind: ConfigMap
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

4. install argo

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

5. install argo cli

```
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```

- http://localhost:8080/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login

6. install istio

TBD

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
