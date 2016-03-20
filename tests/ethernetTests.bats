#!/usr/bin/env bats

. src/helpers.sh
load variables

@test "getEthernetState: get ethernet state" {
  run getEthernetState en4
  [ "$status" -eq 0 ]
  [ "$output" = 1 -o "$output" = 0 ]
}

@test "getEthernetName: get name" {
  run getEthernetName "$LIST"
  [ "$status" -eq 0 ]
  [ "$output" = "Thunderbolt Ethernet" ]
}

@test "getEthernetInterface: get interface" {
  run getEthernetInterface "$LIST"
  [ "$status" -eq 0 ]
  [ "$output" = "en4" ]
}

@test "getEthernetMac: get mac address" {
  run getEthernetMac "$LIST"
  [ "$status" -eq 0 ]
  [ "$output" = "40:0c:8d:00:ef:8c" ]
}
