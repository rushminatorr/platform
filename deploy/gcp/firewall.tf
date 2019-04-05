resource "google_compute_firewall" "vm_firewall" {
  name    = "${google_compute_instance.agent.name}-firewall"
  network = "default"

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
}