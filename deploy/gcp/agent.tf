resource "google_compute_instance" "agent" {
  name = "${var.user}-agent-${random_id.instance_id.hex}"
  machine_type = "f1-micro"
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
   sshKeys = "iofog:${file("creds/id_ecdsa.pub")}"
 }
 // A variable for extracting the external ip of the instance
}
output "ip" {
 value = "${google_compute_instance.agent.network_interface.0.access_config.0.nat_ip}"
}

output "port" {
 value = "${var.agent_port}"
}
