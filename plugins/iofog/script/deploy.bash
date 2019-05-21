#!/bin/bash

set -e

BOOTSTRAP_AGENTS="$1"

OS=$(uname -s | tr A-Z a-z)
SCRIPT=plugins/iofog/script
ANSIBLE=plugins/iofog/ansible
export KUBECONFIG=conf/kube.conf

# Wait for Kubernetes cluster
"$SCRIPT"/wait-for-pods.bash kube-system

# Helm
helm init --wait
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
kubectl rollout status --watch deployment/tiller-deploy -n kube-system
helm repo add iofog https://eclipse-iofog.github.io/helm
helm repo update iofog

# ioFog core on Kubernetes
kubectl create namespace iofog

helm install iofog/iofog --set-string \
controller.image="$CONTROLLER_IMG",\
connector.image="$CONNECTOR_IMG"

echo "Waiting for Controller Pod..."
"$SCRIPT"/wait-for-pods.bash iofog name=controller
echo "Waiting for Connector Pod..."
"$SCRIPT"/wait-for-pods.bash iofog name=connector

echo "Waiting for Controller LoadBalancer IP..."
CTRL_IP=$("$SCRIPT"/wait-for-lb.bash iofog controller)
echo "Waiting for Connector LoadBalancer IP..."
CNCT_IP=$("$SCRIPT"/wait-for-lb.bash iofog connector)

# Configure Controller with Connector IP
CTRL_POD=$(kubectl get pod -l name=controller -n iofog -o jsonpath="{.items[0].metadata.name}")
kubectl exec "$CTRL_POD" -n iofog -- node /controller/src/main connector add -n gke -d connector --dev-mode-on -i "$CNCT_IP"

# Get Auth token from Controller
TOKEN=$("$SCRIPT"/get-controller-token.bash "$CTRL_IP" 51121)

helm install iofog/iofog-k8s --set-string \
controller.token="$TOKEN",\
scheduler.image="$SCHEDULER_IMG",\
operator.image="$OPERATOR_IMG",\
kubelet.image="$KUBELET_IMG"

# Get GKE Controller and Connector IPs and save to config files
echo "$CTRL_IP":51121 > conf/controller.conf
echo "$CNCT_IP":8080 > conf/connector.conf

# Agents
"$SCRIPT"/add-agent-hosts.bash $(cat conf/agents.conf)

if [ "$OS" == "darwin" ]; then
	sed -i '' -e "s/controller_ip=.*/controller_ip=$CTRL_IP/g" "$ANSIBLE"/hosts
else
	sed -i "s/controller_ip=.*/controller_ip=$CTRL_IP/g" "$ANSIBLE"/hosts
fi
if [ "$BOOTSTRAP_AGENTS" = "True" ]; then
	ANSIBLE_CONFIG="$ANSIBLE" ansible-playbook -i "$ANSIBLE"/hosts "$ANSIBLE"/bootstrap.yml
fi
ANSIBLE_CONFIG="$ANSIBLE" ansible-playbook -i "$ANSIBLE"/hosts "$ANSIBLE"/init.yml