# Deployment


## Components
VPC
NAT
IP
dns endpoint
GKE



![components](docs/components.png)

## Prerequisites


### Usage

In the terraform directory, run:

1. *terrafor    m init* to initialize your terraform directory
2. *terraform plan -var-file="vars-dev.tfvars"* pass in your vars file
3. *terraform apply -var-file="vars-dev.tfvars" -auto-approve * apply will create your resources
4. *terraform destroy -var-file="vars-dev.tfvars" -auto-approve * use the destroy command to delete all your resources

| Variables              | Description                                          |
| -----------------------|:----------------------------------------------------:|
| `name`                 | *name *                                              |


## Manual steps



### Helpful Commands


#### To Do
separate project to setup GCP project and IAM
