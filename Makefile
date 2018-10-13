STATE_BUCKET_NAME := tf-state-spinnaker
TERRAFORM_DIR := $(shell pwd)/terraform

init:
	cd "${TERRAFORM_DIR}"; \
	terraform init -backend-config=bucket=${STATE_BUCKET_NAME};

plan:
	cd "${TERRAFORM_DIR}"; \
	terraform plan -out=plan.tfstate

apply:
	cd "${TERRAFORM_DIR}"; \
	terraform apply plan.tfstate

destroy:
	cd "${TERRAFORM_DIR}"; \
	terraform destroy