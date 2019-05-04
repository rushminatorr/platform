#!/bin/bash

set -e

OS=$(uname -s | tr A-Z a-z)
TERRAFORM_VERSION=0.11.13 

# Terraform
if [[ -z $(command -v terraform) ]]; then
    curl -fSL -o terraform.zip https://releases.hashicorp.com/terraform/"$TERRAFORM_VERSION"/terraform_"$TERRAFORM_VERSION"_"$OS"_amd64.zip
    sudo mkdir -p /usr/local/opt/
    sudo unzip -q terraform.zip -d /usr/local/opt/terraform
    rm -f terraform.zip
    sudo ln -s /usr/local/opt/terraform/terraform /usr/local/bin/terraform
else
    echo "Terraform already installed"
    terraform --version
    echo ""
fi