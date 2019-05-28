#!/bin/sh

wait_for_lb()
{
    NAMESPACE="$1"
    SVC="$2"
    EXTERNAL_IP=""
    while [ -z "$EXTERNAL_IP" ] ; do
    EXTERNAL_IP=$(kubectl get svc "$SVC" --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}" -n "$NAMESPACE")
    [ -z "$EXTERNAL_IP" ] && sleep 10
    done

    echo "$EXTERNAL_IP"
}

get_controller_token() 
{
    IP=$1
    PORT=$2

    # Create User
    USER_RESULT=$(curl \--request POST \
    http://"$IP":"$PORT"/api/v3/user/signup \
    --header 'Content-Type: application/json' \
    --data '{ "firstName": "Dev", "lastName": "Test", "email": "user@domain.com", "password": "#Bugs4Fun" }')
    #echo "$USER_RESULT"

    # Get Auth Token
    AUTH_RESULT=$(curl --request POST \
    --url http://"$IP":"$PORT"/api/v3/user/login \
    --header 'Content-Type: application/json' \
    --data '{"email":"user@domain.com","password":"#Bugs4Fun"}')
    #echo "$AUTH_RESULT"

    TOKEN=$(echo $AUTH_RESULT | jq -r .accessToken)

    echo $TOKEN
}

echo "Configuring iofog for cluster $CLUSTER_NAME"

# Helm
echo "Configuring Helm..."
helm init --wait
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
kubectl rollout status --watch deployment/tiller-deploy -n kube-system
helm repo add iofog https://eclipse-iofog.github.io/helm
helm repo update iofog

# ioFog core on Kubernetes
echo "Installing iofog..."
echo "Images:"
echo $SCHEDULER_IMG
echo $CONTROLLER_IMG
echo $CONNECTOR_IMG
echo $OPERATOR_IMG
echo $KUBELET_IMG

kubectl create namespace iofog

helm install iofog/iofog --set-string \
controller.image="$CONTROLLER_IMG",\
connector.image="$CONNECTOR_IMG"

# echo "Waiting for Controller Pod..."
# "$SCRIPT"/wait-for-pods.bash iofog name=controller
# echo "Waiting for Connector Pod..."
# "$SCRIPT"/wait-for-pods.bash iofog name=connector

echo "Waiting for Controller LoadBalancer IP..."
CTRL_IP=$(wait_for_lb iofog controller)
echo "Waiting for Connector LoadBalancer IP..."
CNCT_IP=$(wait_for_lb iofog connector)

# Configure Controller with Connector IP
CTRL_POD=$(kubectl get pod -l name=controller -n iofog -o jsonpath="{.items[0].metadata.name}")
kubectl exec "$CTRL_POD" -n iofog -- node /controller/src/main connector add -n gke -d connector --dev-mode-on -i "$CNCT_IP"

# Get Auth token from Controller
TOKEN=$(get_controller_token "$CTRL_IP" 51121)

helm install iofog/iofog-k8s --set-string \
controller.token="$TOKEN",\
scheduler.image="$SCHEDULER_IMG",\
operator.image="$OPERATOR_IMG",\
kubelet.image="$KUBELET_IMG"
