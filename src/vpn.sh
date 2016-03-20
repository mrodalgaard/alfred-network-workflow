#!/bin/bash

. src/workflowHandler.sh
. src/helpers.sh

while read -r LINE; do
  OUTPUT="$(getVPNInfo "$LINE")"
  IFS='~' read -r -a ARRAY <<< "$OUTPUT"

  addResult "" "${ARRAY[1]}" "${ARRAY[1]}" "${ARRAY[2]} (${ARRAY[0]})" "${ARRAY[3]}"
done <<< "$(echo "$(scutil --nc list)" | awk 'NR>1')"

getXMLResults
