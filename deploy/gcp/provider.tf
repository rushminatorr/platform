provider "google" {
  credentials = "${file("creds/svcacc.json")}"
  project     = "${var.gcp_project}"
  region      = "australia-southeast1"
}