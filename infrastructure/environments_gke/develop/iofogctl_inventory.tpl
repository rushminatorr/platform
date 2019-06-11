controllers:
- name: "${cluster_name}"
  kubeconfig: "~/.kube/config"
  images:
    controller_ip: "${controller_ip}"
    controller_image: "${controller_image}"
    connector_image: "${connector_image}"
    operator_image: "${operator_image}"
    kubelet_image: "${kubelet_image}"
agents:
- name: raspberrypi-develop
  user: root
  host: 207.135.70.110
  port: 55505
  keyfile: "${ssh_key}"
microservices: []