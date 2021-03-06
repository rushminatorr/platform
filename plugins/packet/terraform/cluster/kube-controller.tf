data "template_file" "controller" {
  template = "${file("${path.module}/controller.tpl")}"

  vars {
    kube_token          = "${module.kube_token_1.token}"
    packet_network_cidr = "${packet_reserved_ip_block.kubernetes.cidr_notation}"
    packet_auth_token   = "${file("plugins/packet/creds/packet.token")}"
    packet_project_id = "${var.project_id}"
    kube_version        = "${var.kubernetes_version}"
    secrets_encryption  = "${var.secrets_encryption}"
    configure_ingress   = "${var.configure_ingress}"
  }
}

resource "packet_ssh_key" "cluster_key" {
  name       = "clusterkey"
  public_key = "${file("plugins/packet/creds/id_ecdsa_cluster.pub")}"
}

resource "packet_device" "k8s_primary" {
  hostname         = "${var.cluster_name}-controller"
  operating_system = "ubuntu_18_04"
  plan             = "${var.plan_primary}"
  facility         = "${var.facility}"
  user_data        = "${data.template_file.controller.rendered}"

  billing_cycle = "hourly"
  project_id = "${var.project_id}"
  depends_on       = ["packet_ssh_key.cluster_key"]
}

resource "packet_ip_attachment" "kubernetes_lb_block" {
  device_id     = "${packet_device.k8s_primary.id}"
  cidr_notation = "${packet_reserved_ip_block.kubernetes.cidr_notation}"
}
