SHELL = /bin/bash
OS = $(shell uname -s | tr A-Z a-z)

# Build variables
BRANCH ?= ""
VERSION ?= $(shell git rev-parse --abbrev-ref HEAD)
COMMIT_HASH ?= $(shell git rev-parse --short HEAD 2>/dev/null)
BUILD_DATE ?= $(shell date +%FT%T%z)

# Bootstrap variables
K8S_VERSION ?= 1.13.4
HELM_VERSION ?= 2.13.1
TERRAFORM_VERSION ?= 0.11.13
GCLOUD_VERSION ?= 240.0.0
MINIKUBE_VERSION ?= 0.35.0

# Cloud infra variables
KUBE_CFG := creds/kube.conf
GCP_PROJ ?= "focal-freedom-236620"
PKT_PROJ ?= "880125b9-d7b6-43c3-99f5-abd1af3ce879"
AGENT_USER ?= $(USER) 

################# Bootstrap targets #################
.PHONY: bootstrap
bootstrap: install-helm install-kubectl install-jq install-ansible install-terraform install-gcloud

.PHONY: install-helm
install-helm:
	curl -Lo helm.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-v$(HELM_VERSION)-$(OS)-amd64.tar.gz
	tar -xf helm.tar.gz
	rm helm.tar.gz
	sudo mv $(OS)-amd64/helm /usr/local/bin
	chmod +x /usr/local/bin/helm
	rm -r $(OS)-amd64

.PHONY: install-kubectl
install-kubectl:
	curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v$(K8S_VERSION)/bin/$(OS)/amd64/kubectl
	chmod +x kubectl
	sudo mv kubectl /usr/local/bin/

.PHONY: install-jq
install-jq:
ifeq ($(OS), darwin)
	brew install jq
else
	sudo apt install jq
endif

.PHONY: install-ansible
install-ansible:
	python --version
	sudo easy_install pip
	sudo pip install ansible
	ANSIBLE_CONFIG=./deploy/ansible ansible --version

.PHONY: install-minikube
install-minikube:
	curl -Lo minikube https://storage.googleapis.com/minikube/releases/v$(MINIKUBE_VERSION)/minikube-$(OS)-amd64
	chmod +x minikube
	sudo mv minikube /usr/local/bin/

.PHONY: install-terraform
install-terraform:
	curl -fSL -o terraform.zip https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_$(OS)_amd64.zip
	sudo unzip -q terraform.zip -d /opt/terraform
	rm -f terraform.zip
	sudo ln -s /opt/terraform/terraform /usr/local/bin/terraform

.PHONY: install-gcloud
install-gcloud:
	curl -Lo gcloud.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-$(GCLOUD_VERSION)-$(OS)-x86_64.tar.gz
	tar -xf gcloud.tar.gz
	rm gcloud.tar.gz
	google-cloud-sdk/install.sh -q

################# Top-level deploy targets #################
.PHONY: deploy-gcp
deploy-gcp: setup-gcp init-gcp init-helm deploy-iofog

.PHONY: deploy-packet
deploy-packet: setup-packet init-packet init-helm deploy-iofog

################# Lower-level deploy targets #################
.PHONY: deploy-iofog
deploy-iofog: deploy-k8s-core deploy-k8s-exts deploy-agent

.PHONY: setup-gcp
setup-gcp: export KUBECONFIG=$(KUBE_CFG)
setup-gcp:
	yes | ssh-keygen -t ecdsa -N "" -f creds/id_ecdsa -q
	printenv GCP_SVC_ACC > creds/svcacc.json
	gcloud auth activate-service-account --key-file=creds/svcacc.json
	gcloud config set project $(GCP_PROJ)
	terraform init deploy/gcp
	terraform apply -var user=$(USER) -var gcp_project=$(GCP_PROJ) -auto-approve deploy/gcp

.PHONY: init-gcp
init-gcp: export KUBECONFIG=$(KUBE_CFG)
init-gcp:
	script/wait-for-gke.bash $(shell terraform output name)
	gcloud container clusters get-credentials $(shell terraform output name) --zone $(shell terraform output zone)
	kubectl cluster-info

.PHONY: setup-packet
setup-packet:
	yes | ssh-keygen -t ecdsa -N "" -f creds/id_ecdsa -q
	printenv PKT_TKN | tr -d '\n' > creds/packet.token
	terraform init deploy/packet
	terraform apply -var project_id=$(PKT_PROJ) -auto-approve deploy/packet 

.PHONY: init-packet
init-packet: export KUBECONFIG=$(KUBE_CFG)
init-packet:
	rsync -e "ssh -i creds/id_ecdsa -o StrictHostKeyChecking=no" $(shell terraform output user)@$(shell terraform output host):$(shell terraform output kubeconfig) $(KUBE_CFG)
	kubectl get nodes
	$(eval AGENT_USER=root)
	script/wait-for-pods.bash kube-system

.PHONY: init-helm
init-helm: export KUBECONFIG=$(KUBE_CFG)
init-helm:
	helm init --wait
	kubectl create serviceaccount --namespace kube-system tiller
	kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
	kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
	kubectl rollout status --watch deployment/tiller-deploy -n kube-system

.PHONY: deploy-k8s-core
deploy-k8s-core: export KUBECONFIG=$(KUBE_CFG)
deploy-k8s-core:
	kubectl create namespace iofog
	helm install deploy/helm/iofog
	@echo "Waiting for Controller Pod..."
	script/wait-for-pods.bash iofog name=controller
	@echo "Waiting for Controller LoadBalancer IP..."

.PHONY: deploy-k8s-exts
deploy-k8s-exts: export KUBECONFIG=$(KUBE_CFG)
deploy-k8s-exts:
	$(eval IP=$(shell KUBECONFIG=$(KUBE_CFG) script/wait-for-lb.bash iofog controller))
	$(eval PORT=51121)
	$(eval TOKEN=$(shell script/get-controller-token.bash $(IP) $(PORT)))
	helm install deploy/helm/iofog-k8s --set-string controller.token=$(TOKEN)

.PHONY: deploy-agent
deploy-agent:
	$(eval AGENT_IP=$(shell terraform output agent_ip))
	$(eval CTRL_IP=$(shell KUBECONFIG=$(KUBE_CFG) script/wait-for-lb.bash iofog controller))
ifeq ($(OS), darwin)
	sed -i '' -e '/\[iofog-agent\]/ {' -e 'n; s/.*/$(AGENT_IP)/' -e '}' deploy/ansible/hosts
	sed -i '' -e 's/ansible_user=.*/ansible_user=$(AGENT_USER)/g' deploy/ansible/hosts
	sed -i '' -e 's/controller_ip=.*/controller_ip=$(CTRL_IP)/g' deploy/ansible/hosts
else
	sed -i '/\[iofog-agent\]/!b;n;c$(AGENT_IP)' deploy/ansible/hosts
	sed -i 's/ansible_user=.*/ansible_user=$(AGENT_USER)/g' deploy/ansible/hosts
	sed -i 's/controller_ip=.*/controller_ip=$(CTRL_IP)/g' deploy/ansible/hosts
endif
	ANSIBLE_CONFIG=deploy/ansible ansible-playbook -i deploy/ansible/hosts deploy/ansible/iofog-agent.yml

################# Test targets #################
.PHONY: test
test: export KUBECONFIG=$(KUBE_CFG)
test:
	kubectl apply -f test/weather.yml
	script/wait-for-pods.bash iofog app=weather-demo
	curl http://$(shell terraform output agent_ip):$(shell terraform output agent_port) --connect-timeout 10

################# Teardown targets #################
.PHONY: rm-iofog-k8s
rm-iofog-k8s: export KUBECONFIG=$(KUBE_CFG)
rm-iofog-k8s:
	helm delete --purge $(shell helm ls | awk '$$9 ~ /iofog/ { print $$1 }')
	kubectl delete ns iofog

.PHONY: rm-gcp
rm-gcp:
	terraform destroy -var user=$(USER) -var gcp_project=$(GCP_PROJ) -auto-approve deploy/gcp
	rm -f terraform.tfstate*
	rm -f creds/svcacc.json
	rm -f creds/kube.conf 
	rm -f creds/id_*

.PHONY: rm-packet
rm-packet:
	terraform destroy -var project_id=$(PKT_PROJ) -auto-approve deploy/packet
	rm -f terraform.tfstate*
	rm -f creds/packet.*
	rm -f creds/kube.conf 
	rm -f creds/id_*

.PHONY: clean
clean:
	rm -f creds/svcacc.json || true
	rm -f creds/id_* || true
	rm -f creds/packet.* || true
	rm -f terraform.tfstate* || true
	rm -f creds/kube.conf || true

################# Misc targets #################
.PHONY: push
push:
	script/push.bash $(COMMIT_HASH) $(GIT_USER) $(GIT_EMAIL) $(GIT_TOKEN)

.PHONY: list help
.DEFAULT_GOAL := help
list: ## List all make targets
	@$(MAKE) -pRrn : -f $(MAKEFILE_LIST) 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | sort
help:
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Variable outputting/exporting rules
var-%: ; @echo $($*)
varexport-%: ; @echo $*=$($*)
