resource "google_container_cluster" "gke" {
  name = "${var.user}-${random_id.instance_id.hex}"
  network = "default"
  location = "australia-southeast1"
  initial_node_count = 1
}

output "name" {
  value = "${google_container_cluster.gke.name}"
}
output "zone" {
  value = "${google_container_cluster.gke.location}"
}
