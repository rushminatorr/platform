#!/usr/bin/env bash
CONTROLLER_HOST=$1

token=""
uuid=""

function wait() {
    while true; do
        str=`eval "$1"`
        if [[ ! $str =~ $2 ]]; then
            break
        fi
        sleep .5
    done
}

function login() {
    echo "Logging in"
    login=$(curl --request POST \
        --url $CONTROLLER_HOST/user/login \
        --header 'Content-Type: application/json' \
        --data '{"email":"user@domain.com","password":"#Bugs4Fun"}')
    echo "$login"
    token=$(echo $login | jq -r .accessToken)
}


function create-node() {
    echo "Creating node"
    node=$(curl --request POST \
        --url $CONTROLLER_HOST/iofog \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json' \
        --data '{"name":"agent-smith","fogType":0}')
    echo "$node"
    uuid=$(echo $node | jq -r .uuid)
}

function provision() {
    echo "Provisioning key"
    provisioning=$(curl --request GET \
        --url $CONTROLLER_HOST/iofog/$uuid/provisioning-key \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json')
    echo "$provisioning"
    key=$(echo $provisioning | jq -r .key)

    iofog-agent provision $key
}


#wait "iofog-agent status" "iofog is not running."
#wait "curl --request GET --url $CONTROLLER_HOST/status" "Failed"

# These are our setup steps
login
create-node
provision
