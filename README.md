# Usage

## Deploy on GCP
![img not found](https://raw.githubusercontent.com/iofog/iofog-platform/develop/docs/gcp.png)

Generate a service account on GCP first. Make sure it has access to GCE, GKE, and Service Account Usage.
```
export GCP_SVC_ACC=$(cat path/to/svc.json)
make bootstrap
make deploy-gcp
make test
make rm-gcp
```

## Deploy on Packet
![img not found](https://raw.githubusercontent.com/iofog/iofog-platform/develop/docs/packet.png)

Generate an access token for your Packet account first.
```
export PKT_TKN=$(cat path/to/token)
make bootstrap
make deploy-packet
make test
make rm-packet
```

# ioFog Git and Build Workflow

ioFog is a platform built from a number of services which reside in other repositories. This repository consolidates all of the ioFog services for the purposes of testing and releasing.

![img not found](https://raw.githubusercontent.com/iofog/iofog-platform/develop/docs/artefacts.png)
