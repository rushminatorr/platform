controllers:
- name: "${cluster_name}"
  kubeconfig: "~/.kube/config"
  kubecontrollerip: "${controller_ip}"
  iofoguser:
      name: "${iofogUser_name}"
      surname: "${iofogUser_surname}"
      email: "${iofogUser_email}"
      password: "${iofogUser_password}"
  images:
    controller_image: "${controller_image}"
    connector_image: "${connector_image}"
    operator_image: "${operator_image}"
    kubelet_image: "${kubelet_image}"
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