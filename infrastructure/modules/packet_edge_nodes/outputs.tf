# Packet Output
output "x86_packet_device_ip" {
    description = "Public address for x86 nodes"
    value       = "${packet_device.x86_node.*.network}"
    # value       = [for i in "${packet_device.x86_node.*.network}": i.address if i.family == "4"]
    # value =     [for x in [{id="i-123",zone="us-west"},{id="i-abc",zone="us-east"}]: x.id if x.zone == "us-east"]
    # [for x in [{id="i-123",zone="us-west"},{id="i-abc",zone="us-east"}]: x.id if x.zone == "us-east"]
    # value       = lookup("${packet_device.x86_node.*.network}", key, [default])
}

output "arm_packet_device_ip" {
    description = "Public address for arm nodes"
    value       = "${packet_device.arm_node.*.network}"
}

output edge_nodes {
    description = "Public address for all edge nodes"
    value       = ["${packet_device.x86_node.*.network}",
                    "${packet_device.arm_node.*.network}"]
}