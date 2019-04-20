#!/bin/bash

set -e

PKT_PROJ="880125b9-d7b6-43c3-99f5-abd1af3ce879"
PREFIX=plugins/packet

# Deploy infrastructure
terraform init "$PREFIX"/terraform/edge
terraform apply -var gcp_project="$PKT_PROJ" -auto-approve "$PREFIX"/terraform/edge

# Output files of this job
terraform output agents | tr -d ',' > conf/agents.conf 