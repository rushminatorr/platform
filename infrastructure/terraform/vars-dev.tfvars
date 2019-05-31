# Dev variables
project_id          = "focal-freedom-236620"

## network 
network_name        = "rush"
gcp_region          = "us-west1"

#gke
gke_name            = "rush"

# iofog images
controller_image    = "gcr.io/focal-freedom-236620/controller:develop"
connector_image     = "gcr.io/focal-freedom-236620/connector:develop"
scheduler_image     = "gcr.io/focal-freedom-236620/scheduler:dev-latest"
operator_image      = "gcr.io/focal-freedom-236620/operator:dev-latest"
kubelet_image       = "gcr.io/focal-freedom-236620/kubelet:dev-latest"

#packer

#bold agents
agent_ips           = ["123.234.456.789", "123.345.567.566"]

# ansible
ssh_key             = "~/.ssh/id_ed25519"