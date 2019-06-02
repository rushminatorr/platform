variable "project_id"           {}
variable "environment"          {}
variable "gcp_region"           {}
variable "controller_image"     {}
variable "connector_image"      {}
variable "kubelet_image"        {}
variable "operator_image"       {}
variable "scheduler_image"      {}
variable "ssh_key"              {}
variable "agent_ips"            {}
variable "controller_ip"        {
    default = ""
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

#############################################################
# Setup network vpc and subnets on GCP
#############################################################
module "gcp_network" {
    source  = "../modules/gcp_network"

    project_id                  = "${var.project_id}"
    network_name                = "${var.environment}"
}

#############################################################
# Spin up GKE cluster on GCP after setting up the network 
#############################################################
module "kubernetes" {
    source  = "../modules/gke"

    project_id                  = "${var.project_id}"
    gke_name                    = "${var.environment}"
    gke_region                  = "${var.gcp_region}"
    gke_network_name            = "${module.gcp_network.network_name}"
    gke_subnetwork              = "${module.gcp_network.subnets_names[0]}"
    # service_account         = "${data.google_service_account.svc_account.name}"
    service_account             = "azure-gcr@focal-freedom-236620.iam.gserviceaccount.com"
}

#############################################################
# Install iofog on gke cluster using helm and install scripts 
#############################################################
module "iofog" {
    source  = "../modules/k8s_iofog"

    scheduler_image             = "${var.scheduler_image}"
    operator_image              = "${var.operator_image}"
    kubelet_image               = "${var.kubelet_image}"
    controller_image            = "${var.controller_image}"
    connector_image             = "${var.connector_image}"
    cluster_name                = "${module.kubernetes.name}"
    kubeconfig                  = "${module.kubernetes.kubeconfig}"
    script_path                 = "../modules/k8s_iofog/setup.sh"
}

#############################################################
# Run ansible scripts againsts edge nodes to install agent
#############################################################
resource "null_resource" "ansible" {
    triggers {
        build_number = "${timestamp()}"
    }
    # Fetch the controller ip from iofog installation to pass to agent configuration
    provisioner "local-exec" {
        command = "export TF_VAR_controller_ip=$(kubectl get svc controller --template=\"{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}\" -n iofog) && echo $TF_VAR_controller_ip"
    }
    # Run ansible playbook against edge nodes to install agents
    provisioner "local-exec" {
        command = "ansible-playbook ../ansible/agent.yml --private-key=${var.ssh_key} -e \"controller_ip=$TF_VAR_controller_ip\" -i \"${var.agent_ips}\","
    }
    depends_on = [
        "module.iofog"
    ]
}