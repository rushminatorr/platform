resource "packet_ssh_key" "key1" {
  name       = "automationkey"
  public_key = "${file("creds/id_ecdsa.pub")}"
}

resource "packet_device" "edgy_agent" {
  hostname          = "edgy-agent"
  plan              = "t1.small.x86"
  operating_system  = "ubuntu_16_04"
  billing_cycle     = "hourly"
  project_id        = "${var.project_id}"
  facility          = "${var.facility}"
  depends_on       = ["packet_ssh_key.key1"]
}