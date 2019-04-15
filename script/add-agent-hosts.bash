#!/bin/bash

HOSTS_FILE='deploy/ansible/hosts'

# First clear previous hosts
sed -n '/\[iofog-agent\]/q;p' "$HOSTS_FILE" > /tmp/hosts
cat /tmp/hosts > "$HOSTS_FILE"
echo '[iofog-agent]' >> "$HOSTS_FILE"

# Append new hosts
for HOST in "$@"
do
   echo "$HOST" >> "$HOSTS_FILE"
done