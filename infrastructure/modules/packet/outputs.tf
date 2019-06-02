# Packet Output
output "packet_device_ip" {
    description = "IPv4 or IPv6 address string"
    value       = "${packet_device.packet_agents.network.address}"
}