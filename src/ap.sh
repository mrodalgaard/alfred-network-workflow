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
ACTIVE_BSSID=$(getBSSID "$INFO")

# Sort scan lines and remove header
SORTED=$($AIRPORT --scan | awk 'NR>1' | sort)

if [ "$SORTED" == "" ]; then
  # Handle no wifi access points found
  addResult "" "Null" "No access points found" "" "$ICON_WIFI_ERROR"
else
  # Parse sorted scan lines
  while read -r LINE; do
    OUTPUT=$(getAPDetails "$LINE" "$ACTIVE_BSSID" "$SAVED_APS")
    IFS='~' read -r -a ARRAY <<< "$OUTPUT"

    addResult "" "${ARRAY[0]}" "${ARRAY[0]}" "RSSI ${ARRAY[2]} dBm, channel ${ARRAY[3]}" "${ARRAY[5]}"
  done <<< "$SORTED"
fi

getXMLResults
