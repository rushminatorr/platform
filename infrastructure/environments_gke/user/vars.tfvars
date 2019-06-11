# Dev variables
project_id          = "focal-freedom-236620"
environment         = "rushrush" 
gcp_region          = "us-west1"

# iofog vars
controller_ip       = "" # Static ip for loadbalancer, eompty is fine.
# iofog images
controller_image    = "gcr.io/focal-freedom-236620/controller:1.0.38"
connector_image     = "gcr.io/focal-freedom-236620/connector:1.0.4"
operator_image      = "gcr.io/focal-freedom-236620/operator:rc-1.0.0"
kubelet_image       = "gcr.io/focal-freedom-236620/kubelet:rc-1.0.0"

#packet vars used to setup edge nodes in arm or x86
packet_project_id   = "880125b9-d7b6-43c3-99f5-abd1af3ce879"
operating_system    = "ubuntu_16_04"
packet_facility     = ["sjc1", "ewr1"]             
count_x86           = "0"
plan_x86            = "c1.small.x86"
count_arm           = "0"
plan_arm            = "c2.large.arm"

# used by ansible for agent configuration
ssh_key             = "~/.ssh/azure"
agent_version       = "1.0.14.881"
agent_repo          = "dev"