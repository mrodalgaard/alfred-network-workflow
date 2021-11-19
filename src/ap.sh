#!/bin/bash

. src/wifiCommon.sh
. src/workflowHandler.sh

# Handle action
if [ "$1" != "" ]; then
  if [ "$1" == "Null" ]; then
    exit
  fi

  # Extract password for AP, which is needed by networksetup
  PASS=$(security 2>&1 >/dev/null find-generic-password -ga "$1" \
    | awk '/ / {print $2}' | tr -d '"')
  networksetup -setairportnetwork "$INTERFACE" "$1" "$PASS"
  exit
fi

INFO=$($AIRPORT --getinfo)
SAVED_APS=$(networksetup -listpreferredwirelessnetworks "$INTERFACE")

ACTIVE_ID=$(getBSSID "$INFO")
if [ "$ACTIVE_ID" == "" ]; then
  ACTIVE_ID=$(getSSID "$INFO")
fi

# Scan airport access points and remove header
APS=$($AIRPORT --scan | awk 'NR>1')

if [ "$APS" == "" ]; then
  # Handle no wifi access points found
  addResult "" "Null" "No access points found" "" "$ICON_WIFI_ERROR"
else
  PARSED_APS=''

  # Parse each AP scan line
  while read -r LINE; do
    PARSED_APS+=$(getAPDetails "$LINE" "$ACTIVE_ID" "$SAVED_APS")$'\n'
  done <<< "$APS"

  # Sort parsed access points by priority and name
  PARSED_APS=$(echo "$PARSED_APS" | sort)

  # Sort and create workflow results from each line
  while read -r LINE; do
    IFS='~' read -r -a ARRAY <<< "$LINE"

    if [ "${ARRAY[0]}" != "" ]; then
      addResult "" "${ARRAY[1]}" "${ARRAY[1]}" "RSSI ${ARRAY[3]} dBm, channel ${ARRAY[4]}" "${ARRAY[6]}"
    fi
  done <<< "$PARSED_APS"
fi

getXMLResults
