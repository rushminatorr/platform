#!/bin/bash

set -e

PKT_PROJ="880125b9-d7b6-43c3-99f5-abd1af3ce879"
PREFIX=plugins/packet
export KUBECONFIG=conf/kube.conf

# Generate keys
rm -f "$PREFIX"/creds/id_ecdsa*
ssh-keygen -t ecdsa -N "" -f "$PREFIX"/creds/id_ecdsa -q

# Deploy infrastructure
terraform init "$PREFIX"/terraform
terraform apply -var project_id="$PKT_PROJ" -auto-approve "$PREFIX"/terraform

# Output files of this job
rsync -e "ssh -i $PREFIX/creds/id_ecdsa -o StrictHostKeyChecking=no" $(terraform output user)@$(terraform output host):$(terraform output kubeconfig) "$KUBECONFIG"
terraform output agents | tr -d ',' > conf/agents.conf 
cp "$PREFIX"/creds/id_ecdsa* conf/