.PHONY: clean init plan apply-tf apply
#default environment, can be overwritten: ENV?=prod
ifndef ENVIRONMENT
override ENVIRONMENT = dev
endif
ENV?=$(ENVIRONMENT)
STATE_BUCKET?=aws-lab-kafka-tf-state

init: clean
	tfenv install
	tfenv use
	terraform init -reconfigure -backend-config='bucket=$(STATE_BUCKET)' -var-file=envs/$(ENV).tfvars

plan:
	terraform plan -out terraform.plan -var-file=envs/$(ENV).tfvars -detailed-exitcode

apply-tf:
	terraform apply -auto-approve terraform.plan

apply: 
	bash apply-capture-output.sh

clean:
	@rm -fr terraform.*
