#############################################################
# Spin up packet resources as edge nodes
#############################################################
variable "project_id"         {}
variable "environment"        {}
variable "operating_system"   {}
variable "count_x86"          {}
variable "plan_x86"           {}
variable "count_arm"          {}
variable "plan_arm"           {}
variable "facility"           {
    type = "list"
}

resource "packet_device" "x86_node" {
    hostname                  = "${format("${var.environment}-iofog-x86-%02d", count.index)}"
    operating_system          = "${var.operating_system}"
    count                     = "${var.count_x86}"
    plan                      = "${var.plan_x86}"
    facilities                = "${var.facility}"
    billing_cycle             = "hourly"
    project_id                = "${var.project_id}"
}

resource "packet_device" "arm_node" {
    hostname                  = "${format("${var.environment}-iofog-arm-%02d", count.index)}"
    operating_system          = "${var.operating_system}"
    count                     = "${var.count_arm}"
    plan                      = "${var.plan_arm}"
    facilities                = "${var.facility}"
    billing_cycle             = "hourly"
    project_id                = "${var.project_id}"
}