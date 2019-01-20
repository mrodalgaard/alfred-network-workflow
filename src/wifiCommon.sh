#!/bin/bash

. src/helpers.sh

LIST=$(networksetup -listallhardwareports)
INTERFACE=$(getWifiInterface "$LIST")
NAME=$(getWifiName "$LIST")

AIRPORT="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
