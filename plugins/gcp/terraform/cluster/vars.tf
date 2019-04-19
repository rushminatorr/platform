variable "user" {
  type = "string"
  default = ""
}

variable "gcp_project" {
    type = "string"
    default = ""
}

resource "random_id" "instance_id" {
 byte_length = 8
}