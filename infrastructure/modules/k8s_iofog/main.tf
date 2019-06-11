#############################################################
# Install iofog on k8s cluster using Helm and install script
#############################################################
variable "controller_image"     {}
variable "connector_image"      {}
variable "kubelet_image"        {}
variable "operator_image"       {}
variable "controller_ip"        {}
variable "cluster_name"         {}
variable "kubeconfig"           {}
variable "script_path"          {}

# Add dependency so iofog gets installed after kubeconfig is generated
resource "null_resource" "depends_on" {
  triggers {
    depends_on = "${var.kubeconfig}"
  }
}
resource "null_resource" "iofog" {

    provisioner "local-exec" {
        command = "sh ${var.script_path}"
        # pass in images as env vars
        environment = {
            CLUSTER_NAME    = "${var.cluster_name}"
            OPERATOR_IMG    = "${var.operator_image}"
            KUBELET_IMG     = "${var.kubelet_image}"
            CONTROLLER_IMG  = "${var.controller_image}"
            CONNECTOR_IMG   = "${var.connector_image}"
            CONTROLLER_IP   = "${var.controller_ip}"
        }
    }
    depends_on = [
        "null_resource.depends_on"
    ]
}
