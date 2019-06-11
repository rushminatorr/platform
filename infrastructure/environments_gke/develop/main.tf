variable "project_id"           {}
variable "environment"          {}
variable "gcp_region"           {}
variable "controller_image"     {}
variable "connector_image"      {}
variable "kubelet_image"        {}
variable "operator_image"       {}
variable "scheduler_image"      {}
variable "ssh_key"              {}
variable "agent_version"        {}
variable "agent_repo"           {}
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
# Iofogctl to install iofog and configure agents 
#############################################################
module "iofogctl" {
    source  = "../../modules/iofogctl"

    scheduler_image             = "${var.scheduler_image}"
    operator_image              = "${var.operator_image}"
    kubelet_image               = "${var.kubelet_image}"
    controller_image            = "${var.controller_image}"
    connector_image             = "${var.connector_image}"
    controller_ip               = "${var.controller_ip}"
    cluster_name                = "${module.kubernetes.name}"
    ssh_key                     = "${var.ssh_key}"
    template_path               = "${file("../../environments_gke/develop/iofogctl_inventory.tpl")}"
}

##########################################################################
# Run ansible scripts againsts edge nodes to install agent
# Queries for controller ip from GKE to pass to agents
# Expects env variable PACKAGE_CLOUD_CREDS populated to pass to ansible
# Takes in `package_cloud_creds` to install agent from snapshot repo
##########################################################################
resource "null_resource" "iofogctl_deploy" {
    # Readd when iofogctl is idempotent
    # triggers {
    #     build_number = "${timestamp()}"
    # }

    # use iofogctl to deploy iofoc ecn and configure agents
    # this will use the config template rendered by iofogctl module
    provisioner "local-exec" {
        command = "kubectl get config"
    }
    provisioner "local-exec" {
        command = "ls ~/.kube/ && ls $HOME/.kube/"
    }
    provisioner "local-exec" {
        command = "iofogctl deploy -f iofogctl_inventory.yaml"
    }
    depends_on = [
        "module.iofogctl"
    ]
}