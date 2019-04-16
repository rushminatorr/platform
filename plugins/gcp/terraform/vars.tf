variable "user" {
  type = "string"
  default = ""
}

variable "agent_port" {
    type = "string"
    default = "5555"
}

variable "gcp_project" {
    type = "string"
    default = ""
}

resource "random_id" "instance_id" {
 byte_length = 8
}