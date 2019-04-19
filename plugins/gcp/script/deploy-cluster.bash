#!/bin/bash

set -e

GCP_PROJ=focal-freedom-236620
PREFIX=plugins/gcp
export KUBECONFIG=conf/kube.conf

# Deploy infrastructure
terraform init "$PREFIX"/terraform/cluster
terraform apply -var user="$USER" -var gcp_project="$GCP_PROJ" -auto-approve "$PREFIX"/terraform/cluster

# Wait for Kubernetes cluster
"$PREFIX"/script/wait-for-gke.bash $(terraform output name)

# Update conf/kube.conf
gcloud container clusters get-credentials $(terraform output name) --zone $(terraform output zone)

# Output files of this job
#cp "$PREFIX"/creds/id_ecdsa* conf/