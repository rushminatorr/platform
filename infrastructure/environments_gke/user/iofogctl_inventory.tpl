controllers:
- name: "${cluster_name}"
  kubeconfig: "~/.kube/config"
  kubeControllerIP: "${controller_ip}"
  iofogUser:
      Name: "${iofogUser_name}"
      Surname: "${iofogUser_surname}"
      Email: "${iofogUser_email}"
      Password: "${iofogUser_password}"
  images:
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