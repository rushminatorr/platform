variable "project_id"           {}
variable "network_name"         {}
variable "gcp_region"           {}
variable "gke_name"             {}
variable "controller_image"     {}
variable "connector_image"      {}
variable "kubelet_image"        {}
variable "operator_image"       {}
variable "scheduler_image"      {}
variable "ssh_key"              {}

provider "google" {
    version                     = "~> 2.7.0"
    project                     = "${var.project_id}"
    region                      = "${var.gcp_region}"
}

provider "google-beta" {
    version                     = "~> 2.7.0"
    region                      = "${var.gcp_region}"
}

# provider "packet" {
#     alias  = "packet"
#     auth_token = "${var.auth_token}"
# }

terraform {
    backend "gcs" {
        bucket                  = "terraform-state-edgy-dev"
    }
}

resource "google_service_account" "svc_account" {
    project                     = "${var.project_id}"
    account_id                  = "tf-gke-${var.gke_name}"
    display_name                = "Terraform-managed service account for cluster ${var.gke_name}"
}

resource "google_service_account_iam_binding" "admin-account-iam" {
    service_account_id          = "${google_service_account.svc_account.name}"
    role                        = "roles/iam.serviceAccountAdmin"

    members                     = ["serviceAccount:${google_service_account.svc_account.email}"]
}

# data "google_service_account" "svc_account" {
#     account_id                  = "tf-gke-${var.gke_name}"
# }

module "gcp_network" {
    source  = "../modules/gcp_network"

    project_id                  = "${var.project_id}"
    network_name                = "${var.network_name}"
}

module "kubernetes" {
    source  = "../modules/gke"

    project_id                  = "${var.project_id}"
    gke_name                    = "${var.gke_name}"
    gke_region                  = "${var.gcp_region}"
    gke_network_name            = "${module.gcp_network.network_name}"
    gke_subnetwork              = "${module.gcp_network.subnets_names[0]}"
    # service_account         = "${data.google_service_account.svc_account.name}"
    service_account             = "azure-gcr@focal-freedom-236620.iam.gserviceaccount.com"
}

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

resource "null_resource" "ansible" {
    triggers {
        build_number = "${timestamp()}"
    }
    provisioner "local-exec" {
        command = "ansible-playbook ../ansible/agent.yml -i ../ansible/hosts.ini --private-key=${var.ssh_key}"
    }
    depends_on = [
        "module.iofog"
    ]
}