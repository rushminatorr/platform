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
    controller: "${controller_image}"
    connector: "${connector_image}"
    operator: "${operator_image}"
    kubelet: "${kubelet_image}"
agents: ${agent_list}
microservices: []