tf-init:
	terraform -chdir=infra init	

tf-plan:
	terraform -chdir=infra plan

tf-apply:
	terraform -chdir=infra apply

tf-apply-ci:
	terraform -chdir=infra apply -auto-approve

tf-destroy:
	terraform -chdir=infra destroy

kubeconfig:
	scripts/update-kubeconfig.sh

grafana-initial-creds:
	kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode


