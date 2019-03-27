SHELL = /bin/bash
OS = $(shell uname -s)

# Project variables
PACKAGE = github.com/iofog/iofog-platform

# Build variables
VERSION ?= $(shell git rev-parse --abbrev-ref HEAD)
COMMIT_HASH ?= $(shell git rev-parse --short HEAD 2>/dev/null)
BUILD_DATE ?= $(shell date +%FT%T%z)
K8S_VERSION ?= 1.13.4
MINIKUBE_VERSION ?= 0.35.0
COMPOSE=build/docker-compose.yml

# Variable outputting/exporting rules
var-%: ; @echo $($*)
varexport-%: ; @echo $*=$($*)

# Target rules
.PHONY: install-kubectl install-kind install-minikube
.PHONY: deploy-kind deploy-minikube deploy-iofog
.PHONY: rm-kind rm-minikube rm-iofog
.PHONY: list help
.DEFAULT_GOAL := help

# Targets
install-kubectl: # Install Kubernetes CLI
	curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v$(K8S_VERSION)/bin/linux/amd64/kubectl
	chmod +x kubectl 
	sudo mv kubectl /usr/local/bin/

install-kind: # Install Kubernetes in Docker
	go get sigs.k8s.io/kind
	kind create cluster

install-minikube: # Install Minikube
	curl -Lo minikube https://storage.googleapis.com/minikube/releases/v$(MINIKUBE_VERSION)/minikube-linux-amd64
	chmod +x minikube
	sudo mv minikube /usr/local/bin/

deploy-kind: install-kubectl install-kind# Deploy Kubernetes locally with KinD
	KUBECONFIG=$(shell kind get kubeconfig-path) kubectl cluster-info
	KUBECONFIG=$(shell kind get kubeconfig-path) kubectl get pods --all-namespaces -o wide

deploy-minikube: install-kubectl install-minikube # Deploy kubernetes locally with minikube
	sudo minikube start --vm-driver=none --kubernetes-version=v$(K8S_VERSION) --cpus 1 --memory 1024 --disk-size 2000m
	sudo minikube update-context

deploy-iofog: # Deploy ioFog services
	docker-compose -f $(COMPOSE) pull
	docker-compose -f $(COMPOSE) build
	docker-compose -f $(COMPOSE) up --detach

test: # Run system tests against ioFog services
	@echo 'TODO: Write system tests :)'

push-iofog: # Push ioFog packages
	@echo 'TODO :)'
#	@echo $(DOCKER_PASS) | docker login -u $(DOCKER_USER) --password-stdin
#	for IMG in $(IOFOG_IMGS) ; do \
#		docker push $(IMAGE):$(TAG) ; \
#	done

rm-kind: # Remove KinD cluster
	kind delete cluster

rm-minikube: # Remove Minikube cluster
	sudo minikube stop
	sudo minikube delete

rm-iofog: # Remove iofog services
	docker-compose -f $(COMPOSE) stop
	docker-compose -f $(COMPOSE) down

list: ## List all make targets
	@$(MAKE) -pRrn : -f $(MAKEFILE_LIST) 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | sort

help:
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

