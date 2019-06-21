variable "project_id"               {}
variable "region"                   {}
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
variable "agent_repo"               {}
variable "agent_version"            {}
variable "agent_list"               {
    type = "list"
}

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
        agent_list                  = "${replace(jsonencode(var.agent_list), "/\"([0-9]+\\.?[0-9]*)\"/", "$1")}"
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

##########################################################################
# Run iofogctl to install agent and deploy ecn
# Queries for controller ip from GKE to pass to iofogctl
# Expects env variable PACKAGE_CLOUD_CREDS populated to pass to iofogctl
##########################################################################
resource "null_resource" "iofogctl_deploy" {
    triggers {
        build_number = "${timestamp()}"
    }

    # use iofogctl to deploy iofoc ecn and configure agents
    # this will use the config template rendered by iofogctl module
    provisioner "local-exec" {
        command = "gcloud --quiet beta container clusters get-credentials ${var.cluster_name} --region ${var.region} --project ${var.project_id}"
    }
    # provisioner "local-exec" {
    #     command = "export AGENT_VERSION=${var.agent_version} && iofogctl create namespace iofog || true && iofogctl deploy -f iofogctl_inventory.yaml -n iofog"
    # }
    depends_on = [
        "null_resource.export_rendered_template"
    ]
}
