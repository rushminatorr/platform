controllers:
- name: "${cluster_name}"
  kubeconfig: "~/.kube/config"
  images:
    controller: "${controller_image}"
    connector:  "${connector_image}"
    scheduler: "iofog/iofog-scheduler:develop"
    operator: "${operator_image}"
    kubelet: "${kubelet_image}"
agents:
- name: nano
  user: root
  host: 207.135.70.110
  port: 55504
  keyfile: "${ssh_key}"
- name: deepcam
  user: root
  host: 207.135.70.110
  port: 55507
  keyfile: "${ssh_key}"
microservices: []