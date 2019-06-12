# Packet Output
output edge_nodes {
    description = "Public address for all edge nodes"
    value       = ["${packet_device.x86_node.*.access_public_ipv4}", "${packet_device.arm_node.*.access_public_ipv4}"]
}
