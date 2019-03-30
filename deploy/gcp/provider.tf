provider "google" {
  credentials = "${file("creds/svcacc.json")}"
  project     = "edgeworx"
  region      = "australia-southeast1"
}