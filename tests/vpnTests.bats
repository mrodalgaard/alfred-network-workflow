#!/usr/bin/env bats

. src/helpers.sh
load variables

@test "getVPNInfo: get vpn info" {
  INPUT="* (Disconnected)   65F5A799-4C98-4DA1-87D7-9D605D9D666C PPP --> L2TP       \"My-VPN\"                      [PPP:L2TP]"

  run getVPNInfo "$INPUT"
  IFS='~' read -r -a ARRAY <<< "$output"

  [ "$status" -eq 0 ]
  [ "${ARRAY[0]}" == "Disconnected" ]
  [ "${ARRAY[1]}" == "My-VPN" ]
  [ "${ARRAY[2]}" == "PPP:L2TP" ]
  [ "${ARRAY[3]}" == "$ICON_VPN" ]
}

@test "getVPNInfo: get connected vpn info" {
  INPUT="* (Connected)   65F5A799-4C98-4DA1-87D7-9D605D9D666C PPP --> L2TP       \"Another: VPN\"                      [PPP:L2TP]"

  run getVPNInfo "$INPUT"
  IFS='~' read -r -a ARRAY <<< "$output"

  [ "$status" -eq 0 ]
  [ "${ARRAY[0]}" == "Connected" ]
  [ "${ARRAY[1]}" == "Another: VPN" ]
  [ "${ARRAY[2]}" == "PPP:L2TP" ]
  [ "${ARRAY[3]}" == "$ICON_VPN_CONNECTED" ]
}

@test "getVPNInfo: get other service" {
  INPUT="* (Disconnected)   CBA1BCD8-D18D-4241-9EF4-5656AF69F09A PPP --> Modem (usbserial) \"USB-Serial Controller D\"        [PPP:Modem]"

  run getVPNInfo "$INPUT"
  IFS='~' read -r -a ARRAY <<< "$output"

  [ "$status" -eq 0 ]
  [ "${ARRAY[0]}" == "Disconnected" ]
  [ "${ARRAY[1]}" == "USB-Serial Controller D" ]
  [ "${ARRAY[2]}" == "PPP:Modem" ]
  [ "${ARRAY[3]}" == "$ICON_VPN" ]
}
