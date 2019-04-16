#!/bin/bash

set -e

GCP_PROJ=focal-freedom-236620
PREFIX=plugins/gcp
export KUBECONFIG=conf/kube.conf

# Generate keys
rm -f "$PREFIX"/creds/id_ecdsa*
ssh-keygen -t ecdsa -N "" -f "$PREFIX"/creds/id_ecdsa -q

# Activate gcloud acc
gcloud auth activate-service-account --key-file="$PREFIX"/creds/svcacc.json
gcloud config set project "$GCP_PROJ"

# Deploy infrastructure
terraform init "$PREFIX"/terraform
terraform apply -var user="$USER" -var gcp_project="$GCP_PROJ" -auto-approve "$PREFIX"/terraform

# Wait for Kubernetes cluster
"$PREFIX"/script/wait-for-gke.bash $(terraform output name)

# Update conf/kube.conf
gcloud container clusters get-credentials $(terraform output name) --zone $(terraform output zone)

# Output files of this job
terraform output agents | tr -d ',' > conf/agents.conf 
cp "$PREFIX"/creds/id_ecdsa* conf/