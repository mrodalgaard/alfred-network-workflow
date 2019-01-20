#!/bin/bash

. src/wifiCommon.sh

# Copy defaults to alfred cache dir if they do not exist
FILE=$alfred_workflow_cache/dns.conf
if [ ! -f "$FILE" ]; then
  mkdir -p "$alfred_workflow_cache"
  cp src/default-dns.conf "$FILE"
fi

# Handle action
if [ "$1" != "" ]; then
  if [ "$1" == "EDIT" ]; then
  	open "$FILE"
    exit
  elif [ "$1" == "DEFAULT" ]; then
    DNS="empty"
  else
    DNS=$(echo "$1" | sed 's/ \/ / /g')
  fi

  networksetup -setdnsservers ${NAME%,*} $DNS
  dscacheutil -flushcache
  exit
fi

# TODO: Handle both WiFi and Ethernet connections

DNSSTRING=$(getDNS "$(networksetup -getdnsservers "$NAME")")

# Parse dns config file
while read -r LINE; do
  DNSCONFIG=$(parseDNSLine "$LINE" "$DNSSTRING")
  IFS='~' read -r -a ARRAY <<< "$DNSCONFIG"

  if [ "$ARRAY" != "" ]; then
    addResult "" "${ARRAY[1]}" "${ARRAY[0]}" "${ARRAY[1]}" "${ARRAY[2]}"
  fi
done < "$FILE"

addResult "" "EDIT" "Edit DNS List" "" "$ICON_DNS"

if [ "$DNSSTRING" == "" ]; then
  addResult "" "DEFAULT" "Default DNS (used)" "Default" "$ICON_DNS_USED"
else
  addResult "" "DEFAULT" "Default DNS" "Default" "$ICON_DNS"
fi

getXMLResults
