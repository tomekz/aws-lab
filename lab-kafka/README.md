## Kafka lab
The lab environment will host a Kafka cluster of two nodes using Amazon EC2 instances.
Another set of EC2 instances will host microservices that will produce messages to the Kafka cluster
The entire infrastructure will be deployed using terraform and ansible.
The deployment architecture will be as follows:

TODO - add diagram

The lab will allow me to learn and practice the following:

* [O] Set up the EC2 cluster for kafka deployment:
  - [X] Using terraform provision EC2 instances with Amazon Linux 2 AMI operating system.
  - [o] Ensure that the instances have appropriate security groups, and network settings:
      - [ ] allowing inbound and outbound traffic for Kafka ports (e.g., 9092) only between the EC2 instances within the cluster.
      - [X] allow inbound traffic for SSH (port 22) 
  - [X] Install docker & docker-compose on each EC2 instance to facilitate containerization. Automate this with ansible
* [ ] Set up Kafka on the EC2 cluster:
  - [ ] Install Kafka on one or more EC2 instances within the cluster. 
  - [ ] Configure Kafka to use multiple topics, including the "user-events" topic in this example.
  - [ ] Ensure that the Kafka instances have sufficient resources and are properly networked within the EC2 cluster.
* [ ] Build Docker images for each microservice:
  - [ ] For each microservice (User Service, Email Service, Notification Service, and Feed Service), create a Dockerfile that defines the container image.
  - [ ] Use the appropriate base image for Go applications and specify the necessary dependencies and build instructions.
  - [ ] Build the Docker image for each microservice using a command like docker build -t <image-name> ..
* [ ] Deploy microservices on the EC2 cluster:
  - [ ] Create deployment scripts or use an orchestration tool like Docker Swarm or Kubernetes to manage the deployment process
  - [ ] Launch containers for each microservice on the EC2 instances using the Docker images built earlier.
  - [ ] Configure the microservices to connect to the appropriate Kafka broker(s) and subscribe to the relevant topics.
* [ ] Set up load balancing and networking:
  - [ ] Configure a load balancer (e.g., Elastic Load Balancer) to distribute incoming traffic across the EC2 instances running the microservices.
  - [ ] Ensure that the load balancer is properly configured to handle the gRPC communication ports for each microservice.
* [ ] Configure security:
* [ ] Apply security best practices to secure the EC2 instances, including using security groups to control inbound and outbound traffic, configuring SSL/TLS for gRPC communication, and securing access to Kafka and other services.
* Monitor and scale:
  - [ ] Implement monitoring and logging mechanisms to track the health and performance of the deployed system. Use tools like CloudWatch, Prometheus, or ELK stack for monitoring and log analysis.
  - [ ] Set up autoscaling policies to automatically scale the EC2 cluster based on resource utilization or other metrics.

## How to run

In order to run the project you need to have docker installed on your machine.
You also need to have an AWS account and create an IAM user with programmatic access.
The IAM user should have the minimal set of permissions required to run the terraform code.

* make sure you put your IAM terraform user credentials inside `.aws` folder in the current directory that will be mounted as a volume of the development container 

```bash
# .aws/credentials
[default]
aws_access_key_id = <your access key>
aws_secret_access_key = <your secret key>

# .aws/config
[default]
region = <your region>
```

* start development container

```bash
docker-compose up --build
```

* exec into container

```
docker exec -it lab-kafka-app-1 bash
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
* 
* run `ansible` commands to provision Kafka cluster
  - see the inventory graph
    - `ansible-inventory --graph`
  - check if ansible can connect to EC2 instances
    - `ansible -t ansible-aws-inventory/ all -m ping`
  - run ad-hoc commands
    - `ansible -t ansible-aws-inventory/ all -a "whoami"`
    - `ansible -t ansible-aws-inventory/ all -a "cat /etc/os-release"`
  - run playbook
    - `ansible-playbook ansible-playbooks/jenkins_master.yaml`
    - `ansible-playbook ansible-playbooks/jenkins_worker.yaml --extra-vars master_ip=<master ip>` // <master_ip> is the private IP of the EC2 instance hosting master Jenkins node (lookup in the console)


