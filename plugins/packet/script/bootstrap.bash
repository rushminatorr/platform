#!/bin/bash

set -e

OS=$(uname -s | tr A-Z a-z)
TERRAFORM_VERSION=0.11.13 

# Terraform
curl -fSL -o terraform.zip https://releases.hashicorp.com/terraform/"$TERRAFORM_VERSION"/terraform_"$TERRAFORM_VERSION"_"$OS"_amd64.zip
sudo unzip -q terraform.zip -d /opt/terraform
rm -f terraform.zip
sudo ln -s /opt/terraform/terraform /usr/local/bin/terraform