infra/up:
	make tf-apply-ci
	make kubeconfig
	make argocd/setup
	make argocd/change-password

infra/down:
	scripts/delete-k8s-objects.sh
	make tf-destroy-ci

reboot:
	kubectl delete ns argocd && make tf-apply-ci && kubectl apply -f bootstrap/infra-apps.yaml && make argocd/change-password

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

tf-destroy-ci:
	terraform -chdir=infra destroy -auto-approve

kubeconfig:
	scripts/update-kubeconfig.sh

grafana/get-password:
	kubectl get secret --namespace monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode

grafana/open:
	brave http://grafana.dummycorp.evilsysadmin.click

argocd/setup:
	kubectl apply -f bootstrap/infra-apps.yaml

argocd/change-password:
	scripts/change-argocd-pass.sh

argocd/delete:
	kubectl delete ns argocd


