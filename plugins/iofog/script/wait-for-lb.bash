#!/bin/bash

NAMESPACE="$1"
SVC="$2"
EXTERNAL_IP=""
while [ -z "$EXTERNAL_IP" ] ; do
  EXTERNAL_IP=$(kubectl get svc "$SVC" --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}" -n "$NAMESPACE")
  [ -z "$EXTERNAL_IP" ] && sleep 10
done

echo "$EXTERNAL_IP"