output "Kubernetes_Cluster_Info" {
  value = "\n\n Run: \n\n\t `ssh root@${packet_device.k8s_primary.network.0.address} kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes -w` \n\n To troubleshoot (or monitor) spin-up, check the cloud-init output:\n\n\t `ssh root@${packet_device.k8s_primary.network.0.address} tail -f /var/log/cloud-init-output.log` \n\n The initialization and spin-up process may take 5-7 minutes to complete."
}

output "kubeconfig" {
  value = "/etc/kubernetes/admin.conf"
}
output "user" {
  value = "root"
}

output "host" {
  value = "${packet_device.k8s_primary.network.0.address}"
}

output "agent_ips" {
  value = ["${packet_device.agent_x86.network.0.address}","${packet_device.agent_arm.network.0.address}"]
}
  
output "agent_port" {
 value = "${var.agent_port}"
}