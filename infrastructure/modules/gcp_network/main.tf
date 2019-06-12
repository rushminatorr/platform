#############################################################
# Setup network vpc and subnets on GCP
#############################################################
variable "project_id"       {}
variable "network_name"     {}

# Use vpc module to setup vpc, subnets and pribvate secondary subnets
module "vpc" {
    source                          = "terraform-google-modules/network/google"
    version                         = "0.6.0"
    project_id                      = "${var.project_id}"
    network_name                    = "${var.network_name}"
    routing_mode                    = "GLOBAL"

    subnets = [
        {
            subnet_name             = "${var.network_name}-subnet-01"
            subnet_ip               = "10.10.10.0/24"
            subnet_region           = "us-west1"
            subnet_private_access   = "true"
            subnet_flow_logs        = "true"
        }
    ]

    secondary_ranges = {
        # Private subnet for pods
        "${var.network_name}-subnet-01" = [
            {
                range_name          = "${var.network_name}-pods"
                ip_cidr_range       = "10.20.0.0/18"
            }
        ],
        # Private subnet for services
        "${var.network_name}-subnet-01" = [
            {
                range_name          = "${var.network_name}-services"
                ip_cidr_range       = "10.20.64.0/18"
            }
        ]
    }
}

# Setup firewall rules for the network
resource "google_compute_firewall" "firewall" {
    name    = "${var.network_name}-firewall"
    network = "${module.vpc.network_name}"
        
    # allow http, https, ssh and controller port access
    allow {
        protocol = "tcp"
        ports    = ["22", "80", "443", "8080", "51121"]
    }
}