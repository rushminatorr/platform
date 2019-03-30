resource "google_container_cluster" "gke-cluster" {
  name               = "ci-cluster"
  network            = "default"
  zone               = "australia-southeast1"
  initial_node_count = 2
}