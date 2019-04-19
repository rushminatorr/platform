#!/bin/bash


CONF="$1"
CURR_CONF=$(terraform workspace show)
if [ "$CURR_CONF" != "$CONF" ] ; then
    terraform workspace new "$CONF"
    terraform workspace select "$CONF"
fi