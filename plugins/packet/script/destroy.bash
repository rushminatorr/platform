#!/bin/bash

set -e

CONF="$1"
PROJ="880125b9-d7b6-43c3-99f5-abd1af3ce879"
PREFIX=plugins/packet

terraform init "$PREFIX"/terraform/"$CONF"
terraform destroy -var project_id="$PROJ" -auto-approve "$PREFIX"/terraform/"$CONF"