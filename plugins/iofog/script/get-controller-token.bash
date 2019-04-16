#!/bin/bash

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