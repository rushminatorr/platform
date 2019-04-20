output "user" {
  value = "${var.user}"
}

output "agents" {
  value = ["${var.user}@${packet_device.agent_x86.network.0.address}",
  "${var.user}@${packet_device.agent_arm.network.0.address}"]
}
  
output "agent_port" {
 value = "${var.agent_port}"
}