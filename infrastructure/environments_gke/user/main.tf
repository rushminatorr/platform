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
# Install iofog on gke cluster using helm and install scripts 
#############################################################
module "iofog" {
    source  = "../../modules/k8s_iofog"

    scheduler_image             = "${var.scheduler_image}"
    operator_image              = "${var.operator_image}"
    kubelet_image               = "${var.kubelet_image}"
    controller_image            = "${var.controller_image}"
    connector_image             = "${var.connector_image}"
    controller_ip               = "${var.controller_ip}"
    cluster_name                = "${module.kubernetes.name}"
    kubeconfig                  = "${module.kubernetes.kubeconfig}"
    script_path                 = "../../modules/k8s_iofog/setup.sh"
}

####################################################################
# Run ansible scripts againsts edge nodes to install agent
# Queries for controller ip from GKE to pass to agents
# Takes in `package_cloud_creds` to install agent from snapshot repo
####################################################################
resource "null_resource" "ansible" {
    triggers {
        build_number = "${timestamp()}"
    }
    # Fetch the controller ip from iofog installation to pass to agent configuration
    provisioner "local-exec" {
        command = "export TF_VAR_controller_ip=$(kubectl get svc controller --template=\"{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}\" -n iofog) && echo $TF_VAR_controller_ip" 
    }
    # Run ansible playbook against user provided edge nodes to install agents
    provisioner "local-exec" {
        command = "ansible-playbook ../../ansible/agent.yml --private-key=${var.ssh_key} -e \"controller_ip=$TF_VAR_controller_ip agent_repo=${var.agent_repo} agent_version=${var.agent_version} package_cloud_creds=$TF_VAR_package_cloud_creds\" -i edge_hosts.ini"
    }
    # Fetch Packet agent list
    provisioner "local-exec" { 
        command = "echo Running Agent provisioning on Packet nodes: ${join(",", module.packet_edge_nodes.edge_nodes)}"
    }
    # Run ansible playbook against packet edge nodes to install agents
    provisioner "local-exec" {
        command = "ansible-playbook ../../ansible/agent.yml --private-key=${var.ssh_key} -e \"controller_ip=$TF_VAR_controller_ip agent_repo=${var.agent_repo} agent_version=${var.agent_version} package_cloud_creds=$TF_VAR_package_cloud_creds\" -i \"${join(",", module.packet_edge_nodes.edge_nodes)}\","
    }
    depends_on = [
        "module.iofog"
    ]
}