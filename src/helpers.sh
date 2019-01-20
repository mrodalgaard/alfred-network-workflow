#!/bin/bash

. src/workflowHandler.sh
. src/media.sh

trim () {
  str="$1"
  match=" "
  while [ "${str:0:${#match}}" == "$match" ]; do
    str="${str:${#match}:${#str}}"
  done
  while [ "${str:$((${#str}-${#match}))}" == "$match" ]; do
    str="${str:0:$((${#str} - ${#match}))}"
  done
  echo "$str"
}

getWifiState() {
  local INTERFACE=${1-$INTERFACE}
  if [ "$(networksetup -getairportpower "$INTERFACE" | grep On)" != "" ]; then
    echo 1
  else
    echo 0
  fi
}

getEthernetState() {
  local INTERFACE=${1-$INTERFACE}
  if [ "$INTERFACE" != "" ]; then
    echo 1
  else
    echo 0
  fi
}

getWifiName() {
  local LIST=${1-$(networksetup -listallhardwareports)}
  local DETAILS=$(echo "$LIST" | grep -A 2 -E "Airport$|Wi-Fi$")
  echo "$DETAILS" | grep -Eo "AirPort|Wi-Fi"
}

getEthernetName() {
  local LIST=${1-$(networksetup -listallhardwareports)}
  local DETAILS=$(echo "$LIST" | grep -A 2 -E "Ethernet$")
  echo "$DETAILS" | awk '/Hardware / {print substr($0, index($0, $3))}'
}

getWifiInterface() {
  local LIST=${1-$(networksetup -listallhardwareports)}
  local DETAILS=$(echo "$LIST" | grep -A 2 -E "Airport$|Wi-Fi$")
  echo "$DETAILS" | grep -m 1 -o -e en[0-9]
}

getEthernetInterface() {
  local LIST=${1-$(networksetup -listallhardwareports)}
  local DETAILS=$(echo "$LIST" | grep -A 2 -E "Ethernet$")
  echo "$DETAILS" | grep -m 1 -o -e en[0-9]
}

getWifiMac() {
  local LIST=${1-$(networksetup -listallhardwareports)}
  local DETAILS=$(echo "$LIST" | grep -A 2 -E "Airport$|Wi-Fi$")
  echo "$DETAILS" | awk '/Ethernet Address: / {print substr($0, index($0, $3))}'
}

getEthernetMac() {
  local LIST=${1-$(networksetup -listallhardwareports)}
  local DETAILS=$(echo "$LIST" | grep -A 2 -E "Ethernet$")
  echo "$DETAILS" | awk '/Ethernet Address: / {print substr($0, index($0, $3))}'
}

# $1 = networksetup -getinfo
getConnectionConfig() {
  echo "$1" | grep 'Configuration$'
}

# $1 = networksetup -getinfo
getIPv4() {
  echo "$1" | grep '^IP\saddress' \
    | awk '/ address/ {print substr($0, index($0, $3))}'
}

# $1 = networksetup -getinfo
getIPv6() {
  local IPv6=$(echo "$1" \
    | grep '^IPv6 IP address' \
    | awk '/ address/ {print substr($0, index($0, $4))}')

  if [ "$IPv6" == "none" ]; then
    echo ""
  else
    echo "$IPv6"
  fi
}

# $1 = airport -getinfo
getSSID() {
  echo "$1" | awk '/ SSID/ {print substr($0, index($0, $2))}'
}

# $1 = BSSID string
padBSSID() {
  if [ ${#1} == 17 ]; then
    echo "$1"
  else
    for PART in $(echo "$1" | tr ":" "\n"); do
      if [ "$skipFirst" != "" ]; then
        printf ":"
      fi
      skipFirst=true
      printf "%02s" "$PART"
    done
  fi
}

# $1 = airport -getinfo
getBSSID() {
  local BSSID=$(echo "$1" | awk '/ BSSID/ {print substr($0, index($0, $2))}')
  echo $(padBSSID "$BSSID")
}

# $1 = airport -getinfo
getAuth() {
  echo "$1" | awk '/ link auth/ {print substr($0, index($0, $2))}'
}

# $1 = Dig resolver address (optional)
getGlobalIP() {
  local RESOLVER=${1:-"myip.opendns.com @resolver1.opendns.com"}

  local IP=$(dig +time=2 +tries=1 +short $RESOLVER)
  if [[ "$IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "$IP"
  fi
}

# $1 = scutil --nc list
getVPN() {
  echo "$1" | awk '/\/*.(Connected)/ {print $7}' | tr -d '"'
}

# $1 = `scutil --nc list` lines
getVPNInfo() {
  if [[ "$1" =~ \*[[:space:]]\((.*)\)[[:space:]].*--\>.*\"(.*)\".*\[(.*)\] ]]
  then
    STATE=${BASH_REMATCH[1]}
    NAME=${BASH_REMATCH[2]}
    TYPE=${BASH_REMATCH[3]}
  fi

  if [ "$STATE" == "Connected" ]; then
    AP_ICON=$ICON_VPN_CONNECTED
  else
    AP_ICON=$ICON_VPN
  fi

  echo "$STATE"~"$NAME"~"$TYPE"~"$AP_ICON"
}

# $1 = networksetup -getdnsservers
getDNS() {
  if [[ "$1" != *"any DNS"* ]]; then
    echo $1 | sed 's/ / \/ /g'
  else
    echo ""
  fi
}

# $1 = line of dns config file
# $2 = active dns list
# $! = Separated string of dns config elements
parseDNSLine() {
  IFS=':' read -r -a ARRAY <<< "$1"
  if [[ "${ARRAY[0]}" =~ ^# ]] || [ "${ARRAY[0]}" == "" ] || [ "${ARRAY[1]}" == "" ]; then
    return
  fi

  local ID=$(trim "${ARRAY[0]}")
  local DNS=$(echo "${ARRAY[1]}" | sed 's/ //g' | sed 's/,/ \/ /g')
  local ICON=$ICON_DNS

  if [ "$DNS" == "$2" ]; then
    ICON=$ICON_DNS_USED
    ID="$ID (used)"
  fi

  echo "$ID"~"$DNS"~"$ICON"
}

# $1 = networksetup -listpreferredwirelessnetworks
# $! = Separated string of saved access points
getSavedAPs() {
  while read -r line; do
    OUTPUT=$OUTPUT~$line
  done <<< "$1"
  echo "${OUTPUT:1}"
}

# $1 = List of elements
# $2 = Element to check
listContains() {
  while read -r ITEM; do
    if [ "$ITEM" == "$2" ]; then
      echo 1
    fi
  done <<< "$1"
}

# $1 = Wifi RSSI
# $! = Wifi strength level 1-4
getWifiStrength() {
  if [ "$1" -lt -80 ]; then
    echo 1
  elif [ "$1" -lt -70 ]; then
    echo 2
  elif [ "$1" -lt -60 ]; then
    echo 3
  else
    echo 4
  fi
}

# $1 = `airpot --scan` line
# $2 = BSSID of the active access point (optional)
# $3 = List of favorite access points (optional)
# $! = Separated string of access point settings
getAPDetails() {
  if [[ "$1" =~ [[:space:]]*(.*)[[:space:]]([0-9a-f:]{17})[[:space:]](.*) ]]
  then
    SSID=${BASH_REMATCH[1]}
    BSSID=${BASH_REMATCH[2]}
    RSSI=$(echo ${BASH_REMATCH[3]} | awk '/ / {print $1}')
    CHANNEL=$(echo ${BASH_REMATCH[3]} | awk '/ / {print $2}')
    SECURITY=$(echo ${BASH_REMATCH[3]} | awk '/ / {print substr($0, index($0, $5))}')
  fi

  FAVORITED=$(listContains "$3" "$SSID")

  if [ "$2" == "$BSSID" ]; then
    AP_ICON=$ICON_WIFI_ACTIVE_
  elif [ "$FAVORITED" != "" ]; then
    AP_ICON=$ICON_WIFI_STAR_
  elif [[ "$SECURITY" =~ "NONE" ]]; then
    AP_ICON=$ICON_WIFI_
  else
    AP_ICON=$ICON_WIFI_LOCK_
  fi

  AP_ICON=$AP_ICON$(getWifiStrength "$RSSI")$ICON_END

  echo "$SSID"~"$BSSID"~"$RSSI"~"$CHANNEL"~"$SECURITY"~"$AP_ICON"
}
