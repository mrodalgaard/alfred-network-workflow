#!/bin/bash

. src/wifiCommon.sh
. src/workflowHandler.sh

# Handle action
if [ "$1" != "" ]; then
  if [ "$1" == "On" ] || [ "$1" == "Off" ]; then
  	networksetup -setairportpower "$INTERFACE" "$1"
  else
    echo "$1" | tr -d '\n'
  fi
  exit
fi

# Get interface mac address
MAC=$(getWifiMac)

# Handle Wi-Fi off state
if [ "$(getWifiState "$INTERFACE")" == 0 ]; then
  addResult "" "On" "Turn $NAME on" "$INTERFACE ($MAC)" "$ICON_WIFI_ERROR"
  getXMLResults
  return
fi

# Get network configuration
NETINFO=$(networksetup -getinfo "$NAME")
NETCONFIG=$(getConnectionConfig "$NETINFO")

# Output IPv4
IPv4=$(getIPv4 "$NETINFO")
if [ "$IPv4" != "" ]; then
  addResult "" "$IPv4" "$IPv4" "IPv4 address ($NETCONFIG)" "$ICON_WIFI"
fi

# Output IPv6
IPv6=$(getIPv6 "$NETINFO")
if [ "$IPv6" != "" ]; then
  addResult "" "$IPv6" "$IPv6" "IPv6 address ($NETCONFIG)" "$ICON_WIFI"
fi

# Output WiFi AP info
INFO=$($AIRPORT --getinfo)
SSID=$(getSSID "$INFO")
BSSID=$(getBSSID "$INFO")
AUTH=$(getAuth "$INFO")
if [ "$SSID" != "" ]; then
  addResult "" "$SSID" "$SSID ($BSSID)" "$NAME access point ($AUTH)" "$ICON_WIFI"
fi

# Output global IP
GLOBALIP=$(getGlobalIP)
if [ "$GLOBALIP" != "" ]; then
  addResult "" "$GLOBALIP" "$GLOBALIP" "Global IP" "$ICON_WIFI"
fi

# Output VPN
VPN=$(getVPN "$(scutil --nc list)")
if [ "$VPN" != "" ]; then
  addResult "" "$VPN" "$VPN" "VPN connection" "$ICON_WIFI"
fi

# Output DNS list
DNSSTRING=$(getDNS "$(networksetup -getdnsservers "$NAME")")
if [ "$DNSSTRING" != "" ]; then
  addResult "" "$DNSSTRING" "$DNSSTRING" "DNS list" "$ICON_WIFI"
fi

addResult "" "Off" "Turn $NAME Off" "$INTERFACE ($MAC)" "$ICON_WIFI"

getXMLResults
