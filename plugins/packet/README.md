# Packet Infrastructure Plugin

![img not found](https://raw.githubusercontent.com/eclipse-iofog/platform/develop/plugins/packet/topology.png)

## Bootstrap

Installs Terraform

## Deploy

Spins up x86 Kubernetes nodes and x86 / ARM edge nodes. Produces conf/kube.conf and conf/agents.conf as output.

#### Inputs

`plugins/packet/creds/packet.token` is a Packet access token written to a file.

#### Outputs

`conf/id_ecdsa` and `conf/id_ecdsa.pub` is a key pair for accessing all hosts in conf/agents.conf.

`conf/kube.conf` is output as a typical Kubernetes config file (e.g. ~/.kube/config).

`conf/agents.conf` is output as a newline-separated list of hosts e.g.:``
```
serge@200.100.123.1
ian@123.66.11.3
```

## Test

Basic smoke test.