#!/bin/bash

set -e

PKT_PROJ="880125b9-d7b6-43c3-99f5-abd1af3ce879"
PREFIX=plugins/packet

terraform destroy -var project_id="$PKT_PROJ" -auto-approve "$PREFIX"/terraform