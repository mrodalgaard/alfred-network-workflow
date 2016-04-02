#!/usr/bin/env bats

. src/helpers.sh
load variables

@test "getWifiState: get wifi state" {
  run getWifiState en0
  [ "$status" -eq 0 ]
  [ "$output" = 1 -o "$output" = 0 ]
}

@test "getWifiName: get name" {
  run getWifiName "$LIST"
  [ "$status" -eq 0 ]
  [ "$output" = "Wi-Fi" ]
}

@test "getWifiInterface: get interface" {
  run getWifiInterface "$LIST"
  [ "$status" -eq 0 ]
  [ "$output" = "en0" ]
}

@test "getWifiMac: get mac address" {
  run getWifiMac "$LIST"
  [ "$status" -eq 0 ]
  [ "$output" = "f8:06:c1:00:a3:cc" ]
}

@test "getConnectionConfig: get connection config" {
  run getConnectionConfig "$NETINFO"
  [ "$output" = "DHCP Configuration" ]
}

@test "getIPv4: get IPv4" {
  run getIPv4 "$NETINFO"
  [ "$output" = "192.168.1.100" ]
}

@test "getIPv6: get non-existing IPv6" {
  run getIPv6 "$NETINFO"
  [ "$output" = "" ]
}

@test "getSSID: get SSID" {
  run getSSID "$INFO"
  [ "$output" = "Test-Network" ]
}

@test "getBSSID: get BSSID" {
  run getBSSID "$INFO"
  [ "$output" = "c8:07:19:2c:00:6f" ]
}

@test "getBSSID: zero pads BSSID" {
  run getBSSID "          BSSID: c8:7:19:2c:0:6f"
  [ "$output" = "c8:07:19:2c:00:6f" ]
}

@test "getAuth: get auth" {
  run getAuth "$INFO"
  [ "$output" = "auth: wpa2-psk" ]
}

@test "getGlobalIP: get global IP" {
  run getGlobalIP
  [[ "$output" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
}

@test "getGlobalIP: handle invalid resolver" {
  run getGlobalIP "non-existing"
  [[ "$output" = "" ]]
}

@test "getVPN: get connected VPN" {
  run getVPN "$SCUTIL"
  [ "$output" = "Test-VPN" ]
}
