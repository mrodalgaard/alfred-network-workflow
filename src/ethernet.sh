#!/bin/bash

. src/ethernetCommon.sh
. src/workflowHandler.sh

# Handle action
if [ "$1" != "" ]; then
  echo "$1" | tr -d '\n'
  exit
fi

# Handle ethernet unconnected state
if [ "$(getEthernetState "$INTERFACE")" == 0 ]; then
  addResult "" "" "Not Connected" "Ethernet is not connected" "$ICON_ETH"
  getXMLResults
  return
fi

# Get network configuration
NETINFO=$(networksetup -getinfo Ethernet)
NETCONFIG=$(getConnectionConfig "$NETINFO")

MAC=$(getEthernetMac)
NAME=$(getEthernetName)

# Output IPv4
IPv4=$(getIPv4 "$NETINFO")
if [[ ! -z "$IPv4" ]]; then
  addResult "" "$IPv4" "$IPv4" "IPv4 address ($NETCONFIG)" "$ICON_ETH"
fi

# Output IPv6
IPv6=$(getIPv6 "$NETINFO")
if [ "$IPv6" != "" ]; then
  addResult "" "$IPv6" "$IPv6" "IPv6 address ($NETCONFIG)" "$ICON_ETH"
fi

# Output global IP
GLOBALIP=$(getGlobalIP)
if [ "$GLOBALIP" != "" ]; then
  addResult "" "$GLOBALIP" "$GLOBALIP" "Global IP" "$ICON_ETH"
fi

# Output VPN
SCUTIL=$(scutil --nc list)
VPN=$(getVPN "$SCUTIL")
if [ "$VPN" != "" ]; then
  addResult "" "$VPN" "$VPN" "VPN connection" "$ICON_ETH"
fi

# Output DNS list
DNSSTRING=$(getDNS "$(networksetup -getdnsservers Ethernet)")
if [ "$DNSSTRING" != "" ]; then
  addResult "" "$DNSSTRING" "$DNSSTRING" "DNS list" "$ICON_ETH"
fi

addResult "" "" "$NAME connected" "$INTERFACE ($MAC)" "$ICON_ETH"

getXMLResults
