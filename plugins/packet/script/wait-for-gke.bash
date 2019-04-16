#!/bin/bash

CLUSTER=$1
CTR=0
STATE=$(gcloud container clusters list | awk -v var="$CLUSTER" '{ if($1 == var) { print $8 } }')
while [ "$CTR" -lt 20 ] && [ "RUNNING" != "$STATE" ] ; do
        STATE=$(gcloud container clusters list | awk -v var="$CLUSTER" '{ if($1 == var) { print $8 } }')
        echo "Waiting 15 seconds for cluster $CLUSTER to be ready..."
        sleep "15"
        CTR=$((CTR+1))
done