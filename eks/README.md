# eks

The goal of this mini lab is to deploy a sandbox EKS cluster. It explores two provisioning strategies:
- using `eksctl` cli
- using terraform

Once the cluster is up and running, we will deploy Istio control plane together with the Istio Ingress Gateway.
A sample [application](https://istio.io/latest/docs/examples/bookinfo/) composed of four microservices will be deployed to the cluster.
The microservices will be exposed to the internet via the Istio Ingress Gateway.

## provision using terraform

```shell
# Obtain the ID of the jumpbox instance
# JUMPBOX_NAME should be the name of your jumpbox instance
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$JUMPBOX_NAME" --query "Reservations[*].Instances[*].InstanceId" --output text)
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=lab-eks-jumpbox" --query "Reservations[*].Instances[*].InstanceId" --output text)

# Obtain a running shell to the remote jumpbox via AWS SSM
aws ssm start-session --target $INSTANCE_ID --region eu-central-1
```

### Istalling Utilities, Preparing the Intermediate Certificate Authority

```shell
sudo -i

cd /home/ssm-user

export CLUSTER='lab-eks'
export AWS_REGION='eu-central-1'

mkdir -p scripts

vim scripts/bootstrap.sh (and copy over the contents of the script/bootstrap.sh file)

vim scripts/istio_deploy.sh (and copy over the contents of the script/istio_deploy.sh file)

chmod +x scripts/*.sh

scripts/bootstrap.sh $CLUSTER
```

### Deploying Istio

Execute the following script 

```shell
scripts/istio_deploy.sh $CLUSTER
```

Congratulations, you should have an Istio control plane. To verify run the following command:

```shell
kubectl get pods -n istio-system
```

### Deploying the Bookinfo Application

download the bookinfo yaml definition and apply it to the cluster
```shell
kubectl create namespace bookinfo
kubectl config set-context --current --namespace bookinfo

wget https://raw.githubusercontent.com/istio/istio/release-1.21/samples/bookinfo/platform/kube/bookinfo.yaml 
kubectl apply -f bookinfo.yaml
# confirm that the app is running: 
kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -sS productpage:9080/productpage | grep -o "<title>.*</title>"

```

Enable sidecar injection for the `bookinfo` namespace:
```shell
kubectl label namespace bookinfo istio-injection=enabled
```

Now that the Bookinfo services are up and running, we need to make the application accessible from outside of your Kubernetes cluster, by creating an Istio Gateway and VirtualService.
The required resource definitions are stored in the `istio` directory of this repository.
To expose the gateway to the internet, we would need to provision AWS Network Load Balancer (NLB) and associate it with the Istio Ingress Gateway. (out of the scope of this lab)


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

