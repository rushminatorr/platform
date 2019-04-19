#!/bin/bash

OS=$(uname -s | tr A-Z a-z)
GCLOUD_VERSION=240.0.0
TERRAFORM_VERSION=0.11.13 

# GCP CLI
curl -Lo gcloud.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-"$GCLOUD_VERSION"-"$OS"-x86_64.tar.gz
tar -xf gcloud.tar.gz
rm gcloud.tar.gz
google-cloud-sdk/install.sh -q
rm -r google-cloud-sdk

# Terraform
curl -fSL -o terraform.zip https://releases.hashicorp.com/terraform/"$TERRAFORM_VERSION"/terraform_"$TERRAFORM_VERSION"_"$OS"_amd64.zip
sudo mkdir -p /usr/local/opt/
sudo unzip -q terraform.zip -d /usr/local/opt/terraform
rm -f terraform.zip
sudo ln -s /usr/local/opt/terraform/terraform /usr/local/bin/terraform