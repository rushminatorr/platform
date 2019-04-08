# Usage

To install dependancies, deploy infrastructure on GCP, and deploy ioFog:
```
export GCP_SVC_ACC=$(cat path/to/svc.json)
make bootstrap
make deploy
make test
```

# ioFog Git and Build Workflow

ioFog is a platform built from a number of services which reside in other repositories. This repository consolidates all of the ioFog services for the purposes of testing and releasing.

![alt text](https://raw.githubusercontent.com/iofog/iofog-platform/develop/docs/artefacts.png)
