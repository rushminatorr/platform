#!/bin/bash

set -e

PREFIX=plugins/packet

# Generate keys
rm -f "$PREFIX"/creds/id_ecdsa*
ssh-keygen -t ecdsa -N "" -f "$PREFIX"/creds/id_ecdsa -q