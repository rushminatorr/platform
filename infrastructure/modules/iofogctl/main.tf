variable "controller_image"         {}
variable "connector_image"          {}
variable "kubelet_image"            {}
variable "operator_image"           {}
variable "controller_ip"            {}
variable "cluster_name"             {}
variable "template_path"            {}
variable "ssh_key"                  {}
variable "iofogUser_name"           {}
variable "iofogUser_surname"        {}
variable "iofogUser_email"          {}
variable "iofogUser_password"       {}

data "template_file" "iofogctl" {
    template                        = "${var.template_path}"
    vars = {
        operator_image              = "${var.operator_image}"
        kubelet_image               = "${var.kubelet_image}"
        controller_image            = "${var.controller_image}"
        connector_image             = "${var.connector_image}"
        controller_ip               = "${var.controller_ip}"
        cluster_name                = "${var.cluster_name}"
        ssh_key                     = "${var.ssh_key}"
        iofogUser_name              = "${var.iofogUser_name}"
        iofogUser_surname           = "${var.iofogUser_surname}"
        iofogUser_email             = "${var.iofogUser_email}"
        iofogUser_password          = "${var.iofogUser_password}"
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