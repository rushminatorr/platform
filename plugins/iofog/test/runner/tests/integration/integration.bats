#!/usr/bin/env bats

. tests/functions.bash

importAgents
#importConfig

# Test that the SSH connection to Agents is Valid
@test "Integration SHH Into Agents Checking" {
  RESULT=$(forAgents "echo SSH connected" 0)
  [[ "$RESULT" -eq 0 ]]
}

# Test that Volumes have been mapped across correctly
@test "Integration Volume Checking" {
    RESULT=$(forAgents "test -f FILENAME" 0)
    [[ "$RESULT" -eq 0 ]]
}

@test "Integration Port Checking" {
    RESULT=$(forAgents "telnet localhost $PORTS" 0)
    [[ "$RESULT" -eq 0 ]]
}

@test "Integration Routes Checking" {
    RESULT=$(forAgents "cat /etc" 0)
    [[ "$RESULT" -eq 0 ]]
}

@test "Integration Privileged Checking" {
    RESULT=$(forAgents "telnet localhost $PORTS" 0)
    [[ "$RESULT" -eq 0 ]]
    
    #RESULT="$(docker inspect --format='{{json .Config.ExposedPorts }}' ${CONTAINER_ID})"
    #[[ "$RESULT" -eq 0 ]]
}

@test "Integration Environment Variables Checking" {
    RESULT=$(forAgents "[ ! -z $ENV_VAR ]" 0)
    [[ "$RESULT" -eq 0 ]]
}

