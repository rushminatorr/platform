variable "controller_image"         {}
variable "connector_image"          {}
variable "kubelet_image"            {}
variable "operator_image"           {}
variable "scheduler_image"          {}
variable "controller_ip"            {}
variable "cluster_name"             {}
variable "template_path"            {}
variable "ssh_key"                  {}

data "template_file" "iofogctl" {
    template                        = "${var.template_path}"
    vars = {
        scheduler_image             = "${var.scheduler_image}"
        operator_image              = "${var.operator_image}"
        kubelet_image               = "${var.kubelet_image}"
        controller_image            = "${var.controller_image}"
        connector_image             = "${var.connector_image}"
        controller_ip               = "${var.controller_ip}"
        # cluster_name                = "${module.kubernetes.name}"
        cluster_name                = "${var.scheduler_image}"
        kubeconfig                  = "${var.scheduler_image}"
        ssh_key                     = "${var.ssh_key}"
    }
}
resource "null_resource" "export_rendered_template" {
    triggers {
        build_number = "${timestamp()}"
    }
    provisioner "local-exec" {
        command = "cat > iofogctl_inventory.yaml <<EOL\n${join(",\n", data.template_file.iofogctl.*.rendered)}\nEOL"
    }
}