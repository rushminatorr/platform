
variable "project_id" {
  default = "880125b9-d7b6-43c3-99f5-abd1af3ce879"
}

variable "facility" {
  description = "Packet Facility"
  default     = "ewr1"
}

variable "user" {
  default = "root"
}
variable "agent_port" {
    type = "string"
    default = "5555"
}