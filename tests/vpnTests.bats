#!/usr/bin/env bats

. src/helpers.sh
load variables

@test "getVPNInfo: get vpn info" {
  INPUT="* (Disconnected)   65F5A799-4C98-4DA1-87D7-9D605D9D666C IPSec              \"My-VPN\"                            [IPSec]"

  run getVPNInfo "$INPUT"
  IFS='~' read -r -a ARRAY <<< "$output"

  [ "$status" -eq 0 ]
  [ "${ARRAY[0]}" == "Disconnected" ]
  [ "${ARRAY[1]}" == "My-VPN" ]
  [ "${ARRAY[2]}" == "IPSec" ]
  [ "${ARRAY[3]}" == "$ICON_VPN" ]
}

@test "getVPNInfo: get connected vpn info" {
  INPUT="* (Connected)   65F5A799-4C98-4DA1-87D7-9D605D9D666C IPSec              \"Another: VPN\"                            [IPSec]"

  run getVPNInfo "$INPUT"
  IFS='~' read -r -a ARRAY <<< "$output"

  [ "$status" -eq 0 ]
  [ "${ARRAY[0]}" == "Connected" ]
  [ "${ARRAY[1]}" == "Another: VPN" ]
  [ "${ARRAY[2]}" == "IPSec" ]
  [ "${ARRAY[3]}" == "$ICON_VPN_CONNECTED" ]
}

@test "getVPNInfo: get other service" {
  INPUT="* (Disconnected)   04D2AFD3-F0BC-47BB-9C91-9E9B4F5675A6 PPP --> L2TP       \"Some L2TP VPN\"                     [PPP:L2TP]"

  run getVPNInfo "$INPUT"
  IFS='~' read -r -a ARRAY <<< "$output"

  [ "$status" -eq 0 ]
  [ "${ARRAY[0]}" == "Disconnected" ]
  [ "${ARRAY[1]}" == "Some L2TP VPN" ]
  [ "${ARRAY[2]}" == "PPP:L2TP" ]
  [ "${ARRAY[3]}" == "$ICON_VPN" ]
}
