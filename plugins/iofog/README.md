# ioFog Platform Plugin

![img not found](https://raw.githubusercontent.com/eclipse-iofog/spin/develop/plugins/iofog/artefacts.png)

## Bootstrap

Installs Helm, Kubectl, and Ansible.

## Deploy

Deploys Controller, Connector, Operator, Kubelet, and Scheduler onto cluster represented by conf/kube.conf.

Deploys Agent on all hosts found in conf/agents.conf.

Connects all Agents to Controller.

#### Inputs

`conf/id_ecdsa` and `conf/id_ecdsa.pub` is expected to be a pub/priv key pair for accessing all hosts in conf/agents.conf.

`conf/kube.conf` is expected to be a typical Kubernetes config file (e.g. ~/.kube/config).

`conf/agents.conf` is expected to be a newline-separated list of hosts e.g.:
```
serge@200.100.123.1
ian@123.66.11.3
```

## Test

Basic smoke test.