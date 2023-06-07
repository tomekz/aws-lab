.PHONY: clean init plan apply
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

apply:
	terraform apply -auto-approve terraform.plan
	bash capture-output.sh

destroy:
	terraform destroy -auto-approve -var-file=envs/$(ENV).tfvars

clean:
	@rm -fr terraform.*
