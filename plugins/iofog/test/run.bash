#!/usr/bin/env bash

PREFIX=plugins/iofog/test/docker-compose
SUFFIX=.yml
if [ "local" = $(cat .iofog.state) ] ; then
    SUFFIX=-local.yml
fi
COMPOSE="$PREFIX""$SUFFIX"

# Launch test runner
docker-compose -f "$COMPOSE" pull test-runner
docker-compose -f "$COMPOSE" up \
    --build \
    --abort-on-container-exit \
    --exit-code-from test-runner \
    --force-recreate \
    --renew-anon-volumes

docker-compose -f "$COMPOSE" down -v