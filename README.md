## sandbox for exploring and learning AWS

The goal of this repo is to create a sandbox environment for exploring and learning AWS. I use it as my lab to meet the following learning objectives
* [X] setup docker development container 
  - [X] install aws cli 
  - [X] install terraform
  - [ ] install ansible
- [X] setup terraform and configure it to use aws
- [X] use s3 bucket to store terraform state
- [ ] create VPC using terraform
- [ ] create EC2 instance using terraform
- [ ] setup Jenkins cluster on EC2 
- [ ] setup Ansible to manage Jenkins cluster

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

* run `terraform` commands
  - `terraform init`
  - `terraform plan`
