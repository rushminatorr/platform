#!/bin/bash

set -e

PKT_PROJ="880125b9-d7b6-43c3-99f5-abd1af3ce879"
PREFIX=plugins/packet
export KUBECONFIG=conf/kube.conf


# Deploy infrastructure
terraform init "$PREFIX"/terraform/cluster
terraform apply -var project_id="$PKT_PROJ" -auto-approve "$PREFIX"/terraform/cluster

# Output files of this job
rsync -e "ssh -i $PREFIX/creds/id_ecdsa_cluster -o StrictHostKeyChecking=no" $(terraform output user)@$(terraform output host):$(terraform output kubeconfig) "$KUBECONFIG"