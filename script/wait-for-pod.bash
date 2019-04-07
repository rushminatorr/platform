#!/bin/bash

NAMESPACE="$1"
SELECTOR="$2"
CTR=0
STATE=$(kubectl get pods -l $SELECTOR -n $NAMESPACE --no-headers | awk '{print $3}')
while [ "$CTR" -lt 20 ] && [ "$STATE" != "Running" ] ; do
        STATE=$(kubectl get pods -l $SELECTOR -n $NAMESPACE --no-headers | awk '{print $3}')
        echo "Waiting 30 seconds for pods in namespace $NAMESPACE with labels [$SELECTOR] to be ready..."
        sleep 30
        CTR=$((CTR+1))
done
