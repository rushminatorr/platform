#!/bin/bash

set -e

CONF="$1"
PROJ="880125b9-d7b6-43c3-99f5-abd1af3ce879"
PREFIX=plugins/packet

terraform destroy -var gcp_project="$PROJ" -auto-approve "$PREFIX"/terraform/"$CONF"