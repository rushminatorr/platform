#!/bin/bash

plugins/weather/script/wait-for-pods.bash iofog app=weather-demo
PORT=5555
HOSTS=$(cat conf/agents.conf)
for HOST in "${HOSTS[@]}"
do
    curl http://"${HOST##*@}":"$PORT" --connect-timeout 10
done