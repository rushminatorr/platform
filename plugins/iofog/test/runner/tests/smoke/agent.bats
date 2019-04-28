#!/usr/bin/env bats

. tests/functions.bash

importAgents

@test "Integration SHH Into Agents Checking" {
  RESULT=$(forAgents "iofog-agent status" 4)
  [[ "$RESULT" -eq 4 ]]
}

@test "iofog-agent network_interface" {
  RESULT=$(forAgents "cat /etc/iofog-agent/config.xml | grep '<network_interface>dynamic</network_interface>'" "dynamic")
  [[ "$RESULT" = "dynamic" ]]
}

@test "iofog-agent version" {
  RESULT=$(forAgents "iofog-agent version" "1.0")
  [[ "$RESULT" = "1.0" ]]
}

@test "iofog-agent info" {
  RESULT=$(forAgents "iofog-agent info" "Iofog UUID")
  [[ "$RESULT" = "Iofog UUID" ]]
}

@test "iofog-agent provision BAD" {
  RESULT=$(forAgents "iofog-agent provision asd" "Invalid Provisioning Key")
  [[ "$RESULT" = "Invalid Provisioning Key" ]]
}

@test "iofog-agent config INVALID RAM" {
  RESULT=$(forAgents "iofog-agent config -m 50" "Memory limit range")
  [[ "$RESULT" = "Memory limit range" ]]
}

@test "iofog-agent config RAM string" {
  RESULT=$(forAgents "iofog-agent config -m test" "invalid value")
  [[ "$RESULT" = "invalid value" ]]
}

@test "iofog-agent config VALID RAM" {
  RESULT=$(forAgents "iofog-agent config -m 80" "New Value")
  [[ "$RESULT" = "New Value" ]]
}
