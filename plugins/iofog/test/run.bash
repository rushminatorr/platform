#!/usr/bin/env bash

RUNNER=plugins/iofog/test/runner
# Setup config folder
cp conf/* "$RUNNER"/conf 

# Launch test runner
docker-compose -f "$RUNNER"/docker-compose.yml  up \
    --build \
    --abort-on-container-exit \
    --exit-code-from test-runner

docker-compose -f "$RUNNER"/docker-compose.yml down