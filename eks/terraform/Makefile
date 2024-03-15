.PHONY: clean init plan apply
#default environment, can be overwritten: ENV?=prod
ifndef ENVIRONMENT
override ENVIRONMENT = dev
endif
ENV?=$(ENVIRONMENT)

init: clean
	tfenv install
	tfenv use
	terraform init -upgrade -reconfigure -var-file=envs/$(ENV).tfvars

plan:
	terraform plan -out terraform.plan -var-file=envs/$(ENV).tfvars

apply:
	terraform apply -auto-approve terraform.plan

destroy:
	terraform destroy -auto-approve -var-file=envs/$(ENV).tfvars

clean:
	@rm -fr terraform.*

