#!/bin/bash

NAMESPACE="$1"
SELECTOR="$2"
CTR=0
STATE=$(kubectl get pods -l $SELECTOR -n $NAMESPACE --no-headers | awk '{print $3}')
while [ "$CTR" -lt 40 ] && [ "$STATE" != "Running" ] ; do
        STATE=$(kubectl get pods -l $SELECTOR -n $NAMESPACE --no-headers | awk '{print $3}')
        echo "Waiting 15 seconds for pods in namespace $NAMESPACE with labels [$SELECTOR] to be ready..."
        sleep 15
        CTR=$((CTR+1))
done
