#!/bin/bash

set -e

CONF="$1"
GCP_PROJ=focal-freedom-236620
PREFIX=plugins/gcp

terraform destroy -var user="$USER" -var gcp_project="$GCP_PROJ" -auto-approve "$PREFIX"/terraform/"$CONF"