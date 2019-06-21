variable "project_id"           {}
variable "environment"          {}
variable "gcp_region"           {}
variable "controller_image"     {}
variable "connector_image"      {}
variable "kubelet_image"        {}
variable "operator_image"       {}
variable "ssh_key"              {}
variable "agent_version"        {
     default = ""
}
variable "agent_repo"           {
     default = ""
}
variable "controller_ip"        {
    default = ""
}
# Packet Vars
variable "packet_project_id"    {}
variable "operating_system"     {}
variable "count_x86"            {}
variable "plan_x86"             {}
variable "count_arm"            {}
variable "plan_arm"             {}
variable "packet_facility"      {
    type = "list"
}
# iofog user vars
variable "iofogUser_name"       {}
variable "iofogUser_surname"    {}
variable "iofogUser_email"      {}
variable "iofogUser_password"   {}
variable "agent_list"      {
    type = "list"
    default = []
}

# Store terraform state in GCS backend
terraform {
    backend "gcs" {
        bucket                  = "terraform-state-edgy-dev"
    }
}

provider "google" {
    version                     = "~> 2.7.0"
    project                     = "${var.project_id}"
    region                      = "${var.gcp_region}"
}

provider "google-beta" {
    version                     = "~> 2.7.0"
    region                      = "${var.gcp_region}"
}

provider "packet" {
    version                     = "~> 2.2"
    auth_token                  = "${file("../packet.token")}"
}

#############################################################
# Setup network vpc and subnets on GCP
#############################################################
module "gcp_network" {
    source  = "../../modules/gcp_network"

    project_id                  = "${var.project_id}"
    network_name                = "${var.environment}"
    region                      = "${var.gcp_region}"
}

#############################################################
# Spin up GKE cluster on GCP after setting up the network 
#############################################################
module "kubernetes" {
    source  = "../../modules/gke"

    project_id                  = "${var.project_id}"
    gke_name                    = "${var.environment}"
    gke_region                  = "${var.gcp_region}"
    gke_network_name            = "${module.gcp_network.network_name}"
    gke_subnetwork              = "${module.gcp_network.subnets_names[0]}"
    # service_account         = "${data.google_service_account.svc_account.name}"
    service_account             = "azure-gcr@focal-freedom-236620.iam.gserviceaccount.com"
}

#############################################################
# Spin up edge nodes on Packet
#############################################################
module "packet_edge_nodes" {
    source  = "../../modules/packet_edge_nodes"

    project_id                  = "${var.packet_project_id}"
    operating_system            = "${var.operating_system}"
    facility                    = "${var.packet_facility}"
    count_x86                   = "${var.count_x86}"
    plan_x86                    = "${var.plan_x86}"
    count_arm                   = "${var.count_arm}"
    plan_arm                    = "${var.plan_arm}"
    environment                 = "${var.environment}"
}

#############################################################
# Iofogctl to install iofog and configure agents 
#############################################################
module "iofogctl_template" {
    source  = "../../modules/iofogctl"

    operator_image              = "${var.operator_image}"
    kubelet_image               = "${var.kubelet_image}"
    controller_image            = "${var.controller_image}"
    connector_image             = "${var.connector_image}"
    controller_ip               = "${var.controller_ip}"
    cluster_name                = "${var.environment}"
    ssh_key                     = "${var.ssh_key}"
    iofogUser_name              = "${var.iofogUser_name}"
    iofogUser_surname           = "${var.iofogUser_surname}"
    iofogUser_email             = "${var.iofogUser_email}"
    iofogUser_password          = "${var.iofogUser_password}"
    agent_list                  = "${var.agent_list}"
    template_path               = "${file("../../environments_gke/iofogctl_inventory.tpl")}"
}

##########################################################################
# Run iofogctl to install agent and deploy ecn
# Queries for controller ip from GKE to pass to iofogctl
# Expects env variable PACKAGE_CLOUD_CREDS populated to pass to iofogctl
##########################################################################
resource "null_resource" "iofogctl_deploy" {
    triggers {
        build_number = "${timestamp()}"
    }

    # use iofogctl to deploy iofoc ecn and configure agents
    # this will use the config template rendered by iofogctl module
    provisioner "local-exec" {
        command = "gcloud --quiet beta container clusters get-credentials ${var.environment} --region ${var.gcp_region} --project ${var.project_id} && ls ~/.kube/"
    }
    provisioner "local-exec" {
        command = "export AGENT_VERSION=${var.agent_version} && iofogctl create namespace iofog && iofogctl deploy -f iofogctl_inventory.yaml -n iofog"
    }
    depends_on = [
        "module.iofogctl_template",
        "module.kubernetes"
    ]
}

##########################################################################
# Install and provision Agent software on packet hosts
##########################################################################
resource "null_resource" "packet_agent_deploy" {
    triggers {
        build_number = "${timestamp()}"
    }
    # Fetch Packet agent list
    provisioner "local-exec" { 
        command = "echo Running Agent provisioning on Packet nodes: ${join(",", module.packet_edge_nodes.edge_nodes)}"
    }
    # Fetch the controller ip from iofog installation to pass to agent configuration
    # Run ansible playbook against packet edge nodes to install agents
    provisioner "local-exec" {
        command = "export TF_VAR_controller_ip=$(kubectl get svc controller --template=\"{{range.status.loadBalancer.ingress}}{{.ip}}{{end}}\" -n iofog) && ansible-playbook ../../ansible/agent.yml --private-key=${var.ssh_key} -e \"controller_ip=$TF_VAR_controller_ip package_cloud_creds=$PACKAGE_CLOUD_TOKEN agent_repo=${var.agent_repo} agent_version=${var.agent_version} \" -i \"${join(",", module.packet_edge_nodes.edge_nodes)}\","
    }

    depends_on = [
        "null_resource.iofogctl_deploy",
        "module.packet_edge_nodes"
    ]
}

# resource "null_resource" "packet_agent_deploy" {
#     count = "${var.count_x86 + var.count_arm}" 

#     provisioner "local-exec" {
#         command = "export AGENT_VERSION=${var.agent_version}  && export TF_VAR_controller_ip=$(kubectl get svc controller --template=\"{{range.status.loadBalancer.ingress}}{{.ip}}{{end}}\" -n iofog) && iofogctl deploy agent packet_agent_${count.index} --user root --key-file ${var.ssh_key} --host ${module.packet_edge_nodes.edge_nodes[count.index]}"
#     }
#     depends_on = [
#         "null_resource.iofogctl_deploy",
#         "module.packet_edge_nodes"
#     ]
# }

output "packet_instance_ip_addrs" {
  value = "${module.packet_edge_nodes.edge_nodes}"
}