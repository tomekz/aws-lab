## sandbox for exploring and learning AWS

The goal of this repo is to create a sandbox environment for exploring and learning AWS. I use it as my lab to meet the following learning objectives
* [X] setup docker development container for the controller node
  - [X] install aws cli
  - [X] install terraform
  - [X] install ansible
- [X] setup terraform and configure it to use aws
- [X] use s3 bucket to store terraform state
- [X] setup network resources using terraform
  - [X] create VPC using
  - [X] attach internet gateway to VPC
  - [X] create public subnets
- [X] create EC2 instance 
  - [X] generate ssh key pair for EC2 remote access
- [ ] setup Jenkins cluster on EC2 
  - [ ] setup Ansible template to install Jenkins
  - [ ] setup Ansible AWS Dynamic Inventory
  - [ ] configure terraform provisioner to run Ansible playbook on EC2 provision

## How to run

In order to run the project you need to have docker installed on your machine.
You also need to have an AWS account and create an IAM user with programmatic access.
The IAM user should have the minimal set of permissions required to run the terraform code.

* make sure you put your IAM terraform user credentials inside `src/.aws` folder

```bash
# src/.aws/credentials
[default]
aws_access_key_id = <your access key>
aws_secret_access_key = <your secret key>

# src/.aws/config
[default]
region = <your region>
```

* start development container

```bash
docker-compose up --build
```

* exec into container

```
docker exec -it aws-lab-app-1 bash
```

* run `aws` commands to create s3 bucket to store terraform state

```bash
aws s3api create-bucket --bucket <your bucket name> --region <your region name> --create-bucket-configuration LocationConstraint=<your region name>
```

depending on your region and bucket name you might need to change the `backend.tf` file

```bash
* generate ssh key pair for EC2 remote access (accept the defaults)
```bash
  ssh-keygen -t rsa
```

* run `terraform` commands to provision infrastructure
  - `terraform init`
  - `terraform plan`
  - `terraform apply`

* run `ansible` commands to provision Jenkins cluster
  - check if ansible can connect to EC2 instances
    - `ansible -t ansible-aws-inventory/ all -m ping`
  - run ad-hoc commands
    - `ansible -t ansible-aws-inventory/ all -a "whoami"`
    - `ansible -t ansible-aws-inventory/ all -a "cat /etc/os-release"`
  - run playbook
    - `ansible-playbook -t ansible-aws-inventory/ ansible-playbooks/sample.yml`
