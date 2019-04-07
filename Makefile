SHELL = /bin/bash
OS = $(shell uname -s | tr A-Z a-z)

# Project variables
PACKAGE = github.com/iofog/iofog-platform

# Build variables
VERSION ?= $(shell git rev-parse --abbrev-ref HEAD)
COMMIT_HASH ?= $(shell git rev-parse --short HEAD 2>/dev/null)
BUILD_DATE ?= $(shell date +%FT%T%z)
K8S_VERSION ?= 1.13.4
MINIKUBE_VERSION ?= 0.35.0

# Install deps targets
.PHONY: bootstrap
bootstrap: install-helm install-kubectl install-jq install-ansible install-terraform install-gcloud

.PHONY: install-helm
install-helm:
	curl -Lo helm.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-v2.13.1-$(OS)-amd64.tar.gz
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

.PHONY: install-kind
install-kind:
	go get sigs.k8s.io/kind

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
	curl -fSL -o terraform.zip https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_$(OS)_amd64.zip
	sudo unzip -q terraform.zip -d /opt/terraform
	rm -f terraform.zip
	sudo ln -s /opt/terraform/terraform /usr/local/bin/terraform

.PHONY: install-gcloud
install-gcloud:
	curl -Lo gcloud.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-240.0.0-$(OS)-x86_64.tar.gz
	tar -xf gcloud.tar.gz
	rm gcloud.tar.gz
	google-cloud-sdk/install.sh -q

# Deploy targets
.PHONY: deploy
deploy: gen-creds deploy-gcp init-gke deploy-iofog-k8s deploy-agent

.PHONY: gen-creds
gen-creds:
	ssh-keygen -t ecdsa -N "" -f creds/id_ecdsa -q

.PHONY: deploy-gcp
deploy-gcp: 
	printenv GCP_SVC_ACC > creds/svcacc.json
	gcloud auth activate-service-account --key-file=creds/svcacc.json
	gcloud config set project edgeworx
	terraform init deploy/gcp
	terraform apply -var user=$(USER) -auto-approve deploy/gcp

.PHONY: deploy-kind
deploy-kind: install-kind
	kind create cluster
	$(eval export KUBECONFIG=$(shell kind get kubeconfig-path))
	kubectl cluster-info

.PHONY: deploy-minikube
deploy-minikube: install-minikube
	sudo minikube start --kubernetes-version=v$(K8S_VERSION)
	sudo minikube update-context

.PHONY: init-gke
init-gke:
	script/wait-for-gke.bash
	gcloud container clusters get-credentials $(shell terraform output name) --zone $(shell terraform output zone)
	kubectl cluster-info
	helm init --wait
	kubectl create serviceaccount --namespace kube-system tiller
	kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
	kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
	kubectl rollout status --watch deployment/tiller-deploy -n kube-system

.PHONY: deploy-iofog-k8s
deploy-iofog-k8s: deploy-k8s-core deploy-k8s-exts

.PHONY: deploy-k8s-core
deploy-k8s-core:
	kubectl create namespace iofog
	helm install deploy/helm/iofog
	@echo "Waiting for Controller LoadBalancer IP..."

.PHONY: deploy-k8s-exts
deploy-k8s-exts:
	$(eval IP=$(shell script/wait-for-lb.bash iofog controller))
	$(eval PORT=51121)
	$(eval TOKEN=$(shell script/get-controller-token.bash $(IP) $(PORT)))
	helm install deploy/helm/iofog-k8s --set-string controller.token=$(TOKEN),controller.host=http://$(IP),controller.port=$(PORT)

.PHONY: deploy-agent
deploy-agent:
	$(eval AGENT_IP=$(shell terraform output ip))
ifeq ($(OS), darwin)
	sed -i '' -e '/\[iofog-agent\]/ {' -e 'n; s/.*/$(AGENT_IP)/' -e '}' deploy/ansible/hosts
else
	sed -i '/\[iofog-agent\]/!b;n;c$(AGENT_IP)' deploy/ansible/hosts
endif
	ANSIBLE_CONFIG=deploy/ansible ansible-playbook -i deploy/ansible/hosts deploy/ansible/iofog-agent.yml

# Tests
.PHONY: test
test:
	kubectl apply -f test/weather.yml
	script/wait-for-pod.bash iofog app=weather-demo
	curl http://$(shell terraform output ip):$(shell terraform output port) --connect-timeout 10

# Teardown targets
.PHONY: rm-iofog-k8s
rm-iofog-k8s:
	helm delete --purge $(shell helm ls | awk '$$9 ~ /iofog/ { print $$1 }')
	kubectl delete ns iofog

.PHONY: rm-gcp
rm-gcp:
	printenv GCP_SVC_ACC > creds/svcacc.json
	terraform destroy -var user=$(USER) -auto-approve deploy/gcp

.PHONY: rm-kind
rm-kind:
	kind delete cluster

.PHONY: rm-minikube
rm-minikube:
	sudo minikube stop
	sudo minikube delete

.PHONY: push-imgs
push-imgs:
	@echo 'TODO :)'
#	@echo $(DOCKER_PASS) | docker login -u $(DOCKER_USER) --password-stdin
#	for IMG in $(IOFOG_IMGS) ; do \
#		docker push $(IMAGE):$(TAG) ; \
#	done

.PHONY: clean
clean:
	rm -f creds/svcacc.json || true
	rm -f creds/id_*

.PHONY: list help
.DEFAULT_GOAL := help
list: ## List all make targets
	@$(MAKE) -pRrn : -f $(MAKEFILE_LIST) 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | sort
help:
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Variable outputting/exporting rules
var-%: ; @echo $($*)
varexport-%: ; @echo $*=$($*)
