# GCP Infrastructure Plugin

![img not found](https://raw.githubusercontent.com/eclipse-iofog/platform/develop/plugins/gcp/topology.png)

## Bootstrap

Installs gcloud CLI and Terraform.

## Deploy

Spins up GKE cluster and GCI agent instances. Produces conf/kube.conf and conf/agents.conf as output.

#### Inputs

`plugins/gcp/creds/svcacc.json` is expected to be a service account JSON file.

#### Outputs

`conf/id_ecdsa` and `conf/id_ecdsa.pub` is a key pair for accessing all hosts in conf/agents.conf.

`conf/kube.conf` is output as a typical Kubernetes config file (e.g. ~/.kube/config).

`conf/agents.conf` is output as a newline-separated list of hosts e.g.:
```
serge@200.100.123.1
ian@123.66.11.3
```

## Test

Basic smoke test.