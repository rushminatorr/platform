#!/bin/bash

CTR=2
while [ "$CTR" -lt 32 ] && [ "RUNNING" != "$(gcloud container clusters list | awk 'NR==2 {print $8}')"  ] ; do
        echo "Waiting $CTR seconds for cluster to be ready..."
        sleep "$CTR" 
        CTR=$((CTR*2))
done