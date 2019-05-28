# Dev variables
project_id      = "focal-freedom-236620"

## network 
network_name    = "rush-test"
gcp_region      = "us-west1"

#gke
gke_name        = "rush"
gke_region      = "us-west1"

# iofog images
controller_image = "iofog/controller:dev"
connector_image = "iofog/connector:dev"
scheduler_image = "iofog/iofog-scheduler:develop"
operator_image  = "iofog/iofog-operator:develop"
kubelet_image   = "iofog/iofog-kubelet:develop"