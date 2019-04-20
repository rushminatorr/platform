provider "packet" {
  version    = "1.3.2"
  auth_token   = "${file("plugins/packet/creds/packet.token")}"
}