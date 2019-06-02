#############################################################
# Spin up packet resource as edge node
#############################################################
variable "packet_project_id"        {}
variable "packet_plan"              {}
variable "packet_facility"          {
    type = "list"
}
variable "packet_instance_name"     {}

resource "packet_device" "packet_agents" {
  hostname         = "${var.packet_instance_name}-iofog-agent"
  plan             = "${var.packet_plan}"
  facilities       = "${var.packet_facility}"
  operating_system = "ubuntu_16_04"
  billing_cycle    = "hourly"
  project_id       = "${var.packet_project_id}"
}