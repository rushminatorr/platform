# Deployment
We use Terraform to deploy all infrastructure and ansible to configure remote edge nodes to install agent software.

## Components

- vpc 
- subnets & firewall
- gke
- iofog
- ansible to configure remote agents

![components](docs/components.png)

## Prerequisites

Install tools:
- Terraform (v11*)
- Ansible
- gcloud
- Helm
- Kubectl

Account:
- packet account token exported as an environment variable for packet provider. Command: `export PACKET_AUTH_TOKEN=xxxxx`
- package_cloud account token exported as a terraforn environment variable. Command: `export TF_VAR_package_cloud_creds=xxxxx`
- gcloud account token to deploy to GCP

## Usage

In the terraform directory, run:

1. *terraform init* to initialize your terraform directory
2. *terraform plan -var-file="vars-dev.tfvars"* pass in your vars file
3. *terraform apply -var-file="vars-dev.tfvars" -auto-approve * apply will create your resources
4. *terraform destroy -var-file="vars-dev.tfvars" -auto-approve * use the destroy command to delete all your resources

| Variables              | Description                                                  |
| -----------------------|:------------------------------------------------------------:|
| `project_id`           | *id of your google platform project*                         |
| `environment`          | *unique name for your environment*                           |
| `gcp_region`           | *region to spin up the resources*                            |
| `controller_image`     | *docker image link for controller setup*                     |
| `connector_image`      | *docker image link for connector setup*                      |
| `scheduler_image`      | *docker image link for scheduler setup*                      |
| `operator_image`       | *docker image link for operator setup*                       |
| `kubelet_image`        | *docker image link for kubelet setup*                        |
| `controller_ip`        | *list of edge ips, comma separated to install agent on*      |
| `ssh_key`              | *path to ssh key to be used for accessing edge nodes*        |
| `agent_repo`           | *use `dev` for snapshot repo, else leave empty*              |
| `agent_version`        | *populate if using dev snapshot repo for agent software      |
| `packet_project_id`    | *packet project id to spin reposrces on packet*              |
| `operating_system`     | *operating system for edge nodes on packet*                  |
| `packet_facility`      | *facilities to use to drop agents*                           |
| `count_x86`            | *number of x86(make sure your project plan allow)*           |
| `plan_x86`             | *server plan for device on x86 available on facility chosen* |
| `count_arm`            | *number of arm sgents to spin up*                            |
| `plan_arm`             | *server plan for device on arm available on facility chosen* |
                   

## Ansible Playbook for Agent Configuration

We use ansible to configure edge nodes with Agent software. You can provide comma separated list of ips as input that will be passed in as hosts to provision agent software on. 

See sample command Terraform uses to run the playbook to provision agents.
If you wish to provision a set of agent, just populate the host file and run teh following command providing with the inputs.

`ansible-playbook agent.yml --private-key=<<PATH_TO_SSH_KEY>> -e \"controller_ip=<<CONTROLLER_IP>> agent_repo=<<AGENT_REPO>> agent_version=<<AGENT_VERSION>> package_cloud_creds=<<PACKAGE_CLOUD_CREDS>>\" -i edge_hosts.ini`

### Helpful Commands

Login to gcloud: `gcloud auth login`
Kubeconfig for gke cluster: `gcloud container clusters get-credentials <<CLUSTER_NAME>> --region <<REGION>>`
Delete a particular terraform resource: `terraform destroy -target=null_resource.iofog -var-file=vars-develop.tfvars -auto-approve`
Terraform OUtput `terraform output -module=packet_edge_nodes`

### To Do
- separate project to setup GCP project and IAM
- setup ansible role to install agent package provided as input
- user provided subnets and network configuration
- update packet module to allow multiple instance creation - count var
- packet resources creation optional based on input
- export TF_VAR_package_cloud_creds
- user - no bucket