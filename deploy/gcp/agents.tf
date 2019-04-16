resource "google_compute_instance" "agent_1" {
  name = "${var.user}-agent-1-${random_id.instance_id.hex}"
  machine_type = "g1-small"
  zone = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network       = "default"
    access_config = {
    }
  }

  metadata {
   sshKeys = "${var.user}:${file("creds/id_ecdsa.pub")}"
 }
}
resource "google_compute_instance" "agent_2" {
  name = "${var.user}-agent-2-${random_id.instance_id.hex}"
  machine_type = "g1-small"
  zone = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network       = "default"
    access_config = {
    }
  }

  metadata {
   sshKeys = "${var.user}:${file("creds/id_ecdsa.pub")}"
 }
}
output "agent_ips" {
 value = ["${google_compute_instance.agent_1.network_interface.0.access_config.0.nat_ip}", "${google_compute_instance.agent_2.network_interface.0.access_config.0.nat_ip}"]
}

output "agent_port" {
 value = "${var.agent_port}"
}
