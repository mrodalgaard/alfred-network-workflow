#!/usr/bin/env bats

. src/helpers.sh
load variables

@test "getSavedAPs: get saved access points" {
  run getSavedAPs "$SAVED_APS"
  IFS='~' read -r -a ARRAY <<< "$output"

  [ "$status" -eq 0 ]
  [ "${ARRAY[0]}" == "Test-Network" ]
  [ "${ARRAY[1]}" == "Test-Network2" ]
  [ "${ARRAY[2]}" == "Martins iPhone" ]
}

@test "getAPDetails: get AP" {
  INPUT="   Test-Network 21:aa:4c:b4:cc:11 -24  6       Y  US WPA2(PSK/AES/AES)"

  run getAPDetails "$INPUT"
  IFS='~' read -r -a ARRAY <<< "$output"

  [ "$status" -eq 0 ]
  [ "${ARRAY[0]}" == "Test-Network" ]
  [ "${ARRAY[1]}" == "21:aa:4c:b4:cc:11" ]
  [ "${ARRAY[2]}" == "-24" ]
  [ "${ARRAY[3]}" == "6" ]
  [ "${ARRAY[4]}" == "WPA2(PSK/AES/AES)" ]
  [ "${ARRAY[5]}" == "$ICON_WIFI_LOCK" ]
}

@test "getAPDetails: get multiband AP with spaces" {
  INPUT="        New AP 50:1d:bf:56:2f:2e -54  132,+1  Y  DK WPA2(PSK/AES/AES) "

  run getAPDetails "$INPUT"
  IFS='~' read -r -a ARRAY <<< "$output"

  [ "${ARRAY[0]}" == "New AP" ]
  [ "${ARRAY[1]}" == "50:1d:bf:56:2f:2e" ]
  [ "${ARRAY[2]}" == "-54" ]
  [ "${ARRAY[3]}" == "132,+1" ]
  [ "${ARRAY[4]}" == "WPA2(PSK/AES/AES)" ]
  [ "${ARRAY[5]}" == "$ICON_WIFI_LOCK" ]
}

@test "getAPDetails: get random printer AP" {
  INPUT="   HP-Print-02-Officejet Pro 8600 9c:b6:54:58:05:02 -79  4       N  -- WPA2(PSK/AES/AES) "

  run getAPDetails "$INPUT"
  IFS='~' read -r -a ARRAY <<< "$output"

  [ "${ARRAY[0]}" == "HP-Print-02-Officejet Pro 8600" ]
  [ "${ARRAY[1]}" == "9c:b6:54:58:05:02" ]
  [ "${ARRAY[2]}" == "-79" ]
  [ "${ARRAY[3]}" == "4" ]
  [ "${ARRAY[4]}" == "WPA2(PSK/AES/AES)" ]
  [ "${ARRAY[5]}" == "$ICON_WIFI_LOCK_2" ]
}

@test "getAPDetails: get unknown AP" {
  INPUT="      test 08:61:6e:c0:9b:ff -27  11      Y  -- WPA(PSK/AES,TKIP/TKIP) WPA2(PSK/AES,TKIP/TKIP)"

  run getAPDetails "$INPUT"
  IFS='~' read -r -a ARRAY <<< "$output"

  [ "${ARRAY[0]}" == "test" ]
  [ "${ARRAY[1]}" == "08:61:6e:c0:9b:ff" ]
  [ "${ARRAY[4]}" == "WPA(PSK/AES,TKIP/TKIP) WPA2(PSK/AES,TKIP/TKIP)" ]
  [ "${ARRAY[5]}" == "$ICON_WIFI_LOCK" ]
}

@test "getAPDetails: active AP is marked with an icon" {
  INPUT="        New AP 50:1d:bf:56:2f:2e -54  132,+1  Y  DK WPA2(PSK/AES/AES) "

  run getAPDetails "$INPUT" "50:1d:bf:56:2f:2e"
  IFS='~' read -r -a ARRAY <<< "$output"

  [ "${ARRAY[0]}" == "New AP" ]
  [ "${ARRAY[1]}" == "50:1d:bf:56:2f:2e" ]
  [ "${ARRAY[5]}" == "$ICON_WIFI_ACTIVE" ]
}

@test "getAPDetails: active BSSID can contain starting zeros" {
  INPUT="        New AP 50:0d:0f:56:00:2e -54  132,+1  Y  DK WPA2(PSK/AES/AES) "

  run getAPDetails "$INPUT" "50:0d:0f:56:00:2e"
  IFS='~' read -r -a ARRAY <<< "$output"

  [ "${ARRAY[0]}" == "New AP" ]
  [ "${ARRAY[1]}" == "50:0d:0f:56:00:2e" ]
  [ "${ARRAY[5]}" == "$ICON_WIFI_ACTIVE" ]
}

@test "getAPDetails: favorited AP is marked with an icon" {
  INPUT="        New AP 50:1d:bf:56:2f:2e -54  132,+1  Y  DK WPA2(PSK/AES/AES) "
  AP_LIST="New AP
  Random other AP"

  run getAPDetails "$INPUT" "1234" "$AP_LIST"
  IFS='~' read -r -a ARRAY <<< "$output"

  [ "${ARRAY[0]}" == "New AP" ]
  [ "${ARRAY[1]}" == "50:1d:bf:56:2f:2e" ]
  [ "${ARRAY[5]}" == "$ICON_WIFI_STAR" ]
}

@test "getAPDetails: open AP is marked with a plain icon" {
  INPUT="        New AP 50:1d:bf:56:2f:2e -54  132,+1  Y  DK NONE "

  run getAPDetails "$INPUT"
  IFS='~' read -r -a ARRAY <<< "$output"

  [ "${ARRAY[0]}" == "New AP" ]
  [ "${ARRAY[5]}" == "$ICON_WIFI" ]
}

@test "getAPDetails: icon is set according to strength" {
  INPUT="        New AP 50:1d:bf:56:2f:2e -55  1  Y  US NONE "
  run getAPDetails "$INPUT"
  IFS='~' read -r -a ARRAY <<< "$output"
  [ "${ARRAY[5]}" == "$ICON_WIFI_4" ]

  INPUT="        New AP 50:1d:bf:56:2f:2e -65  1  Y  US NONE "
  run getAPDetails "$INPUT"
  IFS='~' read -r -a ARRAY <<< "$output"
  [ "${ARRAY[5]}" == "$ICON_WIFI_3" ]

  INPUT="        New AP 50:1d:bf:56:2f:2e -75  1  Y  US NONE "
  run getAPDetails "$INPUT"
  IFS='~' read -r -a ARRAY <<< "$output"
  [ "${ARRAY[5]}" == "$ICON_WIFI_2" ]

  INPUT="        New AP 50:1d:bf:56:2f:2e -85  1  Y  US NONE "
  run getAPDetails "$INPUT"
  IFS='~' read -r -a ARRAY <<< "$output"
  [ "${ARRAY[5]}" == "$ICON_WIFI_1" ]
}

@test "listContains: contains element" {
  run listContains "$AP_LIST" "bar baz"
  [ "$status" -eq 0 ]
  [ "$output" == 1 ]
}

@test "listContains: does not contain element" {
  run listContains "$AP_LIST" "not"
  [ "$output" == "" ]
}

@test "listContains: list is empty" {
  run listContains "" "foo"
  [ "$output" == "" ]
}

@test "listContains: element is empty" {
  run listContains "$AP_LIST"
  [ "$output" == "" ]
}
