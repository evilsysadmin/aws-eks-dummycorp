ENV ?= dev

tf-init:
	terraform -chdir=terraform init	

tf-plan: tf-init tf-fmt
	terraform -chdir=terraform plan -var-file=../environments/$(ENV)/terraform.tfvars

tf-apply:
	terraform -chdir=terraform apply-var-file=../environments/$(ENV)/terraform.tfvars

tf-apply-ci:
	terraform -chdir=terraform apply -auto-approve -var-file=../environments/$(ENV)/terraform.tfvars

tf-destroy:
	terraform -chdir=terraform destroy

tf-fmt:
	terraform -chdir=terraform fmt

kubeconfig:
	scripts/update-kubeconfig.sh

grafana-initial-creds:
	kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode

# Utility commands
kubectl-config:
	aws eks update-kubeconfig --region eu-west-1 --name $(shell cd terraform && terraform output -raw eks_cluster_name)

clean:
	find terraform -name ".terraform" -type d -exec rm -rf {} +
	find terraform -name "terraform.tfstate*" -delete

help:
	@echo "Available commands:"
	@echo "  make tf-plan [ENV=dev]    - Plan deployment"
	@echo "  make tf-apply [ENV=dev]   - Apply deployment"  
	@echo "  make tf-destroy [ENV=dev] - Destroy infrastructure"
	@echo "  make kubectl-config       - Configure kubectl"
	@echo ""
	@echo "Usage examples:"
	@echo "  make tf-apply              # Deploy to dev (default)"
	@echo "  make tf-apply ENV=prod     # Deploy to prod"
	@echo "  ENV=staging make tf-plan   # Plan staging deployment"

