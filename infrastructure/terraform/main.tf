variable "project_id"           {}
/////////////////// Network Vars ///////////////////
variable "network_name"         {}
variable "gcp_region"           {}

/////////////////// Network Vars ///////////////////
variable "gke_name"             {}
variable "gke_region"           {}

////////////////// Images Iofog ////////////////////
variable "controller_image"     {}
variable "connector_image"      {}
variable "kubelet_image"        {}
variable "operator_image"       {}
variable "scheduler_image"      {}


provider "google" {
    version                     = "~> 2.7.0"
    project                     = "${var.project_id}"
    region                      = "${var.gcp_region}"
}

provider "google-beta" {
    version                     = "~> 2.7.0"
    region                      = "${var.gcp_region}"
}

# provider "helm" {
#     version                     = "~> 0.9.1"
#     kubernetes {
#         load_config_file        = false
#         host                    = "https://${module.kubernetes.endpoint}"
#         token                   = "${data.google_client_config.default.access_token}"
#         cluster_ca_certificate  = "${base64decode(module.kubernetes.ca_certificate)}"
#     }
# }

# provider "kubernetes" {
#     version                     = "~> 1.7"
#     load_config_file            = false
#     host                        = "https://${module.kubernetes.endpoint}"
#     token                       = "${data.google_client_config.default.access_token}"
#     cluster_ca_certificate      = "${base64decode(module.kubernetes.ca_certificate)}"
# }

# provider "packet" {
#     alias  = "packet"
#     auth_token = "${var.auth_token}"
# }

# terraform {
#     backend "gcs" {
#         bucket                  = "terraform-state-edgy-dev"
#     }
# }

# data "google_client_config" "default" {}

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
    gke_region                  = "${var.gke_region}"
    gke_network_name            = "${module.gcp_network.network_name}"
    gke_subnetwork              = "${module.gcp_network.subnets_names[0]}"
    # service_account         = "${data.google_service_account.svc_account.name}"
    service_account             = "azure-gcr@focal-freedom-236620.iam.gserviceaccount.com"
}

resource "null_resource" "kube_config" {
    provisioner "local-exec" {
        command = "gcloud --quiet beta container clusters get-credentials $CLUSTER --region $REGION --project $PROJECT"

        environment = {
            CLUSTER   = "${var.gke_name}"
            REGION    = "${var.gke_region}"
            PROJECT   = "${var.project_id}"
        }
    }

    depends_on = [
        "module.gcp_network",
        "module.kubernetes"
    ]
}

module "iofog" {
    source  = "../modules/k8s_iofog"

    scheduler_image             = "${var.scheduler_image}"
    operator_image              = "${var.operator_image}"
    kubelet_image               = "${var.kubelet_image}"
    controller_image            = "${var.controller_image}"
    connector_image             = "${var.connector_image}"
}

# resource "null_resource" "helm_iofog" {
#   provisioner "local-exec" {
#     command = "chmod u+x setup.sh && ./setup.sh"

#     environment = {
#       SCHEDULER_IMG = "iofog/iofog-scheduler:develop"
#       OPERATOR_IMG = "iofog/iofog-operator:develop"
#       KUBELET_IMG = "iofog/iofog-kubelet:develop"
#       CONTROLLER_IMG = "edgeworx/controller-k8s:latest"
#       CONNECTOR_IMG = "iofog/connector:dev"
#     }
#   }

#   depends_on = [
#     "null_resource.kube_config",
#     "module.kubernetes"
#   ]
# }