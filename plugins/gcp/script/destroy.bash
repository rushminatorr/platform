#!/bin/bash

set -e

GCP_PROJ=focal-freedom-236620
PREFIX=plugins/gcp

terraform destroy -var user="$USER" -var gcp_project="$GCP_PROJ" -auto-approve "$PREFIX"/terraform
rm -f terraform.tfstate* "$PREFIX"/creds/svcacc.json "$PREFIX"/creds/kube.conf "$PREFIX"/creds/id_*