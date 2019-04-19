#!/bin/bash

set -e

GCP_PROJ=focal-freedom-236620
PREFIX=plugins/gcp

# Generate keys
rm -f "$PREFIX"/creds/id_ecdsa*
ssh-keygen -t ecdsa -N "" -f "$PREFIX"/creds/id_ecdsa -q

# Activate gcloud acc
gcloud auth activate-service-account --key-file="$PREFIX"/creds/svcacc.json
gcloud config set project "$GCP_PROJ"