variable "project_id"           {}
variable "environment"          {}
variable "gcp_region"           {}
variable "controller_image"     {}
variable "connector_image"      {}
variable "kubelet_image"        {}
variable "operator_image"       {}
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
# iofog user vars
variable "iofogUser_name"       {}
variable "iofogUser_surname"    {}
variable "iofogUser_email"      {}
variable "iofogUser_password"   {}

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
    iofogUser_password           = "${var.iofogUser_password}"
    template_path               = "${file("../../environments_gke/develop/iofogctl_inventory.tpl")}"
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
        command = "export AGENT_VERSION=${var.agent_version} && iofogctl deploy -f iofogctl_inventory.yaml"
    }
    depends_on = [
        "module.iofogctl_template",
        "module.kubernetes"
    ]
}