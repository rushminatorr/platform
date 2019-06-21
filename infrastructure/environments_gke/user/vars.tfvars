# Dev variables
project_id          = "YOUR GOOGLE PROJECT ID"
environment         = "YOUR CHOICE OF NAME FOR YOUR ENVIRONMENT" 
gcp_region          = "us-west2"

# iofog vars
controller_ip       = "" # Static ip for loadbalancer, eompty is fine.
# iofog images
controller_image    = "iofog/controller"
connector_image     = "iofog/connector"
operator_image      = "iofog/iofog-operator"
kubelet_image       = "iofog/iofog-kubelet"

#packet sample vars used to setup edge nodes in arm or x86
packet_project_id   = "YOUR PACKET PROJECT ID"
operating_system    = "ubuntu_16_04"
packet_facility     = ["sjc1", "ewr1"]             
count_x86           = "1"
plan_x86            = "c1.small.x86"
count_arm           = "0"
plan_arm            = "c2.large.arm"
# used by ansible for agent configuration on packet
ssh_key             = "~/.ssh/id"

# iofog user vars
iofogUser_name      = "iofog"
iofogUser_surname   = "edgeworx"          
iofogUser_email     = "iohog@edgeworx.io"          
iofogUser_password  = "edgyEdge"     

# You will need to export the agent snapshot package cloud token as env var(PACKAGE_CLOUD_CREDS) to access the dev repo
# uncomment these if using dev repo
# agent_repo          = "dev" 
# agent_version       = "1.0.14-b1245"
