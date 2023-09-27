#!/bin/bash

. src/workflowHandler.sh
. src/helpers.sh

# Handle action
if [ "$1" != "" ]; then
  IS_CONNECTED=$(test -z `scutil --nc status "$1" | head -n 1 | grep Connected` && echo 0 || echo 1);
  if [ $IS_CONNECTED -eq 1 ]; then
    scutil --nc stop "$1"
  else
    scutil --nc show "$1" | head -1 | grep PPP:L2TP 2>&1 > /dev/null
    if [ $? -eq 0 ]; then
      networksetup -connectpppoeservice "$1"
    else  
      scutil --nc start "$1"
    fi
  fi

  exit
fi

while read -r LINE; do
  OUTPUT="$(getVPNInfo "$LINE")"
  IFS='~' read -r -a ARRAY <<< "$OUTPUT"

  addResult "" "${ARRAY[1]}" "${ARRAY[1]}" "${ARRAY[2]} (${ARRAY[0]})" "${ARRAY[3]}"
done <<< "$(echo "$(scutil --nc list)" | awk 'NR>1')"

getXMLResults
