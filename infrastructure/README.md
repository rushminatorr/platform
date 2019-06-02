# Deployment


## Components
VPC, subnets
GKE
iofog



![components](docs/components.png)

## Prerequisites

Install tools:
- Terraform (v11*)
- Ansible
- gcloud
- Helm
- Kubectl

Account:
- packet account token
- gcloud account token

## Usage

In the terraform directory, run:

1. *terraform init* to initialize your terraform directory
2. *terraform plan -var-file="vars-dev.tfvars"* pass in your vars file
3. *terraform apply -var-file="vars-dev.tfvars" -auto-approve * apply will create your resources
4. *terraform destroy -var-file="vars-dev.tfvars" -auto-approve * use the destroy command to delete all your resources

| Variables              | Description                                          |
| -----------------------|:----------------------------------------------------:|
| `name`                 | *name *                                              |

## Ansible Playbook
`ansible-playbook agent.yml -e "controller_ip=104.196.230.239" --private-key=~/.ssh/azure -i 147.75.46.161,`
## Manual steps


### Helpful Commands
Login to gcloud: `gcloud auth login`
Kubeconfig for gke cluster: `gcloud container clusters get-credentials <<CLUSTER_NAME>> --region <<REGION>>`

#### To Do
separate project to setup GCP project and IAM
setup ansible role to install agent package provided as input
user provided subnets and network configuration
update packet module to allow multiple instance creation - count var
if packet vars empty, do not ask for token