#!/bin/bash

set -e

export KUBECONFIG=conf/kube.conf

SCRIPT=plugins/iofog/script

CTRL_IP=$("$SCRIPT"/wait-for-lb.bash iofog controller)
CONTROLLER=http://"$CTRL_IP":51121/api/v3

echo "Logging in"
LOGIN=$(curl --request POST \
    --url $CONTROLLER/user/login \
    --header 'Content-Type: application/json' \
    --data '{"email":"user@domain.com","password":"#Bugs4Fun"}')
echo "$LOGIN"
TOKEN=$(echo "$LOGIN" | jq -r .accessToken)

echo "Getting list of agents"
LIST=$(curl --request GET \
    --url $CONTROLLER/iofog-list \
    --header 'Content-Type: application/json' \
    --header "Authorization: $TOKEN" )
echo "$LIST"

AGENT_COUNT=$(echo "$LIST" | jq '.fogs | length')
MAX=$((AGENT_COUNT-1))
for IDX in $(seq 0 "$MAX"); do
    UUID=$(echo "$LIST" | jq -r .fogs["$IDX"].uuid)
    echo "Deleting agent $UUID"

    DEL=$(curl --request DELETE \
        --url $CONTROLLER/iofog/"$UUID" \
        --header 'Content-Type: application/json' \
        --header "Authorization: $TOKEN" )
    echo "$DEL"
done


echo 'Waiting for Kubernetes cluster to reconcile with Controller'
ITER=0
until helm delete --purge $(helm ls 2> /dev/null | awk '$9 ~ /iofog/ { print $1 }') &> /dev/null
do
    ITER=$((ITER+1))
    if [[ ITER -gt 20 ]]; then exit 1; fi
    sleep 5
done

kubectl delete ns iofog
helm reset
kubectl delete serviceaccount --namespace kube-system tiller
kubectl delete clusterrolebinding tiller-cluster-rule