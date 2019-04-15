#!/bin/bash

PORT="$1"
shift
for HOST in "$@"
do
    curl http://"$HOST":"$PORT" --connect-timeout 10
done