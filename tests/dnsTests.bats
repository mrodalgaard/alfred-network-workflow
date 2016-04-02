#!/usr/bin/env bats

. src/helpers.sh
load variables

@test "getDNS: get current DNS list" {
  run getDNS "$DNS"
  [ "$output" = "8.8.8.8 / 8.8.4.4 / 192.168.1.1" ]
}

@test "parseDNSLine: parse a single dns config line" {
  run parseDNSLine "Google DNS:8.8.8.8,8.8.4.4"
  IFS='~' read -r -a ARRAY <<< "$output"
  [ "$status" -eq 0 ]
  [ "${ARRAY[0]}" == "Google DNS" ]
  [ "${ARRAY[1]}" == "8.8.8.8 / 8.8.4.4" ]
  [ "${ARRAY[2]}" == "$ICON_DNS" ]
}

@test "parseDNSLine: parse simple config" {
  run parseDNSLine "OpenerDNS:42.120.21.30"
  IFS='~' read -r -a ARRAY <<< "$output"
  [ "${ARRAY[0]}" == "OpenerDNS" ]
  [ "${ARRAY[1]}" == "42.120.21.30" ]
}

@test "parseDNSLine: parse with spaces" {
  run parseDNSLine "  Random DNS  :  1.2.3.4 , 6.7.8.9"
  IFS='~' read -r -a ARRAY <<< "$output"
  [ "${ARRAY[0]}" == "Random DNS" ]
  [ "${ARRAY[1]}" == "1.2.3.4 / 6.7.8.9" ]
}

@test "parseDNSLine: ignore comments" {
  run parseDNSLine "# comment"
  IFS='~' read -r -a ARRAY <<< "$output"
  [ "${ARRAY[0]}" == "" ]
}

@test "parseDNSLine: ignore comments with separator" {
  run parseDNSLine "# comment: this is a comment"
  IFS='~' read -r -a ARRAY <<< "$output"
  [ "${ARRAY[0]}" == "" ]
}

@test "parseDNSLine: ignore empty lines" {
  run parseDNSLine "  "
  IFS='~' read -r -a ARRAY <<< "$output"
  [ "${ARRAY[0]}" == "" ]
}

@test "parseDNSLine: set used state" {
  run parseDNSLine "Google DNS:8.8.8.8,8.8.4.4" "8.8.8.8 / 8.8.4.4"
  IFS='~' read -r -a ARRAY <<< "$output"
  [ "${ARRAY[0]}" == "Google DNS (used)" ]
  [ "${ARRAY[1]}" == "8.8.8.8 / 8.8.4.4" ]
  [ "${ARRAY[2]}" == "$ICON_DNS_USED" ]
}

@test "parseDNSLine: handle invalid line" {
  run parseDNSLine "Invalid 1.2.3.4"
  IFS='~' read -r -a ARRAY <<< "$output"
  [ "${ARRAY[0]}" == "" ]
}

@test "parseDNSLine: handle missing ip" {
  run parseDNSLine "Invalid:"
  IFS='~' read -r -a ARRAY <<< "$output"
  [ "${ARRAY[0]}" == "" ]
}
