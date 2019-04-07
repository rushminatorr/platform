resource "google_compute_firewall" "agent_firewall" {
  name    = "${google_compute_instance.agent.name}-firewall"
  network = "default"

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports = ["5555"]
  }
}