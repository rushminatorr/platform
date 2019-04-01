resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance2"
  machine_type = "f1-micro"
  zone = "us-central1-a"
  #location     = "australia-southeast1"

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
   sshKeys = "drluckyspin:${file("creds/id_tod.pub")}\nkiltonhopkins:${file("creds/id_klt.pub")}\nserge:${file("creds/id_srg.pub")}\nrashmi:${file("creds/id_rsh.pub")}"
 }
 // A variable for extracting the external ip of the instance
}
output "ip" {
 value = "${google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip}"
}