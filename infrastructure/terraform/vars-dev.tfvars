# Dev variables
project_id          = "focal-freedom-236620"
environment         = "dev"
gcp_region          = "us-west1"

# iofog images
controller_image    = "gcr.io/focal-freedom-236620/controller:develop"
connector_image     = "gcr.io/focal-freedom-236620/connector:develop"
scheduler_image     = "gcr.io/focal-freedom-236620/scheduler:dev-latest"
operator_image      = "gcr.io/focal-freedom-236620/operator:dev-latest"
kubelet_image       = "gcr.io/focal-freedom-236620/kubelet:dev-latest"

#packet
packet_project_id   = "880125b9-d7b6-43c3-99f5-abd1af3ce879"
packet_plan         = "c2.large.arm"
packet_facility     = ["sjc1"]

#bold agents
agent_ips           = "207.135.70.110"

# ansible
ssh_key             = "~/.ssh/azure"