#!/bin/bash

export KUBECONFIG=conf/kube.conf
helm delete --purge $(helm ls | awk '$9 ~ /iofog/ { print $1 }')
kubectl delete ns iofog

helm reset

kubectl delete serviceaccount --namespace kube-system tiller
kubectl delete clusterrolebinding tiller-cluster-rule

# TODO: remove agents?