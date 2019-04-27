#!/bin/bash

set -e

GCP_PROJ=focal-freedom-236620
PREFIX=plugins/gcp

# Deploy infrastructure
terraform init "$PREFIX"/terraform/edge
terraform apply -var user="$USER" -var gcp_project="$GCP_PROJ" -auto-approve "$PREFIX"/terraform/edge

# Output files of this job
terraform output agents | tr -d ',' > conf/agents.conf