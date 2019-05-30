variable "controller_image"     {}
variable "connector_image"      {}
variable "kubelet_image"        {}
variable "operator_image"       {}
variable "scheduler_image"      {}
variable "cluster_name"         {}

resource "null_resource" "iofog" {

    provisioner "local-exec" {
        command = "ls -lA && sh setup.sh"

        environment = {
            CLUSTER_NAME    = "${var.cluster_name}"
            SCHEDULER_IMG   = "${var.scheduler_image}"
            OPERATOR_IMG    = "${var.operator_image}"
            KUBELET_IMG     = "${var.kubelet_image}"
            CONTROLLER_IMG  = "${var.controller_image}"
            CONNECTOR_IMG   = "${var.connector_image}"
        }
    }
}