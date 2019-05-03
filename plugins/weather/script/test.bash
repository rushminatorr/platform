#!/bin/bash

set -e

plugins/weather/script/wait-for-pods.bash iofog app=weather-demo
PORT=5555
while IFS= read -r HOST
do
    echo ""
    echo "Testing Agent: ${HOST##*@}"
    echo ""
    curl http://"${HOST##*@}":"$PORT" --connect-timeout 10
    echo ""
done < conf/agents.conf