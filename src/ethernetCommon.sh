#!/bin/bash

. src/helpers.sh

LIST=$(networksetup -listallhardwareports)
INTERFACE=$(getEthernetInterface "$LIST")
NAME=$(getEthernetName "$LIST")
