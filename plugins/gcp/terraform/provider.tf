provider "google" {
  credentials = "${file("plugins/gcp/creds/svcacc.json")}"
  project     = "${var.gcp_project}"
  region      = "australia-southeast1"
}