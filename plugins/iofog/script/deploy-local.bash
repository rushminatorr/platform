#!/bin/bash

echo 'iofog-connector:8080' > conf/connector.conf
echo 'iofog-controller:51121' > conf/controller.conf
echo 'root@iofog-agent' > conf/agents.conf
rm conf/id_ecdsa*
ssh-keygen -t ecdsa -N "" -f conf/id_ecdsa -q
cp conf/id_ecdsa.pub plugins/iofog/local/iofog-agent

docker-compose -f plugins/iofog/local/docker-compose.yml up --build --detach