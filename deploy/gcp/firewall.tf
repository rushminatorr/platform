resource "google_compute_firewall" "agent_firewall" {
  name = "${var.user}-${random_id.instance_id.hex}"
  network = "default"

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports = ["5555"]
  }
}