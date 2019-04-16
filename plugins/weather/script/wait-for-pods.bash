#!/bin/bash

NAMESPACE="$1"
SELECTOR="$2"
CTR=0
RDY_CNT=0
STATE_CNT=1
while [ "$CTR" -lt 20 ] && [ "$RDY_CNT" != "$STATE_CNT" ] ; do
        if [ -z "$SELECTOR" ]
        then
            STATES=$(kubectl get pods -n $NAMESPACE --no-headers | awk '{print $3}')
        else
            STATES=$(kubectl get pods -l $SELECTOR -n $NAMESPACE --no-headers | awk '{print $3}')
        fi
        STATE_CNT=$(echo "$STATES" | wc -l | tr -d '[:space:]')
        RDY_CNT=$(echo "$STATES" | grep Running | wc -l | tr -d '[:space:]')
        echo "$RDY_CNT/$STATE_CNT pods ready"

        [ "$RDY_CNT" != "$STATE_CNT" ] && echo "Waiting 15 seconds for pods in namespace $NAMESPACE with labels [$SELECTOR] to be ready..." && sleep 15
        CTR=$((CTR+1))
done
