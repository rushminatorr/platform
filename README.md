# ioFog Platform

ioFog Platform provides a means by which to orchestrate and test ioFog deployments on various infrastructure.

## iofog CLI

Automation of ioFog Platform is handled through the ioFog CLI. The CLI consumes a number of plugins for the deployment infrastructure and services.

![img not found](https://raw.githubusercontent.com/eclipse-iofog/platform/develop/cli.png)

To create a plugin, you must implement a Python module in the plugins folder.

plugins/gcp is an example of an infrastructure deployment plugin.

plugins/iofog is an example of a platform deployment plugin.

plugins/weather is an example of a service deployment plugin.

Each plugin must provide a README.md as to its required inputs and expected outputs. Plugins have arbitrary inputs and outputs in the form of various configuration files. Chaining plugins together through configuration files allows us to decouple invocations of different plugins. You can therefore think of each plugin as a batch job where configuration files are their inputs and outputs.

The following is an example of how you can bootstrap, deploy, and test an entire infrastructure, platform and service deployment:
```
# Infrastructure
python cli.py up gcp --bootstrap=true
python cli.py test gcp

# Platform
python cli.py up iofog --bootstrap=true
python cli.py test iofog

# Service
python cli.py up weather --bootstrap=true
python cli.py test weather

# Check status / info
python cli.py describe weather
python cli.py describe iofog
python cli.py describe gcp

# Clean up
python cli.py down weather
python cli.py down iofog
python cli.py down gcp
```
