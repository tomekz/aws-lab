# eks

The goal of this mini lab is to deploy a sandbox EKS cluster. It explores two provisioning strategies:
- using `eksctl` cli
- using terraform

## provision using eksctl

### Creating a cluster

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

### Exploring the outcomes

eksctl get clusters --region eu-central-1

kubectl get nodes

eksctl utils describe-addon-versions \
    --cluster devops-catalog \
    --region us-east-2

### Destroying the cluster

eksctl delete cluster  --config-file eks/cluster.yaml  --wait


## provision using terraform

```shell
# Obtain the ID of the jumpbox instance
# JUMPBOX_NAME should be the name of your jumpbox instance
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$JUMPBOX_NAME" --query "Reservations[*].Instances[*].InstanceId" --output text)
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=lab-eks-jumpbox" --query "Reservations[*].Instances[*].InstanceId" --output text)

# Obtain a running shell to the remote jumpbox via AWS SSM
aws ssm [start session](start-session) --target $INSTANCE_ID --region eu-central-1
aws ssm start-session --target i-0b30b6d2ccf208b70 --region eu-central-1
```

### Istalling Utilities, Preparing the Intermediate Certificate Authority

```shell
sudo -i

cd /home/ssm-user

export CLUSTERS='lab-eks'
export AWS_REGION='eu-west-1'

mkdir -p scripts

vim scripts/bootstrap.sh (and copy over the contents of the script/bootstrap.sh file)

chmod +x scripts/*.sh

scripts/bootstrap.sh $CLUSTERS
```

Upon successful execution of the script, the ssm-user home directory should look similar to this (you should have the ca-cert, key and a cert-chain for your cluster):

### Deploying Istio

Execute the following script (still within the jumpbox in a root shell session):

```shell
scripts/istio_deploy.sh $CLUSTER
```

Congratulations, you should have an Istio control plane. To verify run the following command:

```shell
kubectl get pods -n istio-system
```


# TODO
- [X] add https://eksctl.io/ to dev container
- [.] automate:
   - [x] create and destroy new eks cluster using eksctl
      - [x] create and destroy new eks cluster using aws
    - [ ] deploy istio to eks cluster
        - [ ] use [cloud-init](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html) module to run user scripts on EC2 instance
        - [ ] pass the `yaml.tpl` files to the cloud-init module using terraform `templatefile` function like this: __
        ```terraform
        locals {
              cloud_init = base64encode(templatefile("${path.module}/user-data/cloud_init.yml.tpl", { istio_values_yml = local.istio_values_yml, helmfile = local.helmfile, rootca_pkey = local.rootca_pkey, rootca = local.rootca, intca_pkey = local.intca_pkey, intca = local.intca }))
        }
        ```
        - [ ] install Utilities, Preparing the Intermediate Certificate Authority
        - [ ] deploy istio

