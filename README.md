# Spin

Spin is an orchestration utility. It is designed to deploy any infrastructure, platforms, and services that are exposed as plugins. 

![img not found](https://raw.githubusercontent.com/eclipse-iofog/spin/develop/spin.png)

To create a plugin, you must implement a Python module in the plugins folder.

plugins/gcp is an example of an infrastructure deployment plugin.

plugins/iofog is an example of a platform deployment plugin.

plugins/weather is an example of a service deployment plugin.

Each plugin must provide a README.md as to its required inputs and expected outputs. Plugins have arbitrary inputs and outputs in the form of various configuration files. Chaining plugins together through configuration files allows us to decouple invocations of different plugins. You can therefore think of each plugin as a batch job where configuration files are their inputs and outputs.

The following is an example of how you can bootstrap, deploy, and test an entire infrastructure, platform and service deployment:
```
# Infrastructure
python spin.py up gcp --bootstrap=true
python spin.py test gcp

# Platform
python spin.py up iofog --bootstrap=true
python spin.py test iofog

# Service
python spin.py up weather --bootstrap=true
python spin.py test weather

# Check status / info
python spin.py describe weather
python spin.py describe iofog
python spin.py describe gcp

# Clean up
python spin.py down weather
python spin.py down iofog
python spin.py down gcp
```
