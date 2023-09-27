#!/bin/bash

. src/workflowHandler.sh
. src/media.sh

ETHERNET_REGEX="LAN$|Lan$|Ethernet$|AX[0-9A-Z]+$"
WIFI_REGEX="Airport$|Wi-Fi$"

PRIORITY_HIGH="1"
PRIORITY_MEDIUM="2"
PRIORITY_LOW="5"

# Trim string
# $1 = Input string
# $! = Trimmed string
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

# Get wifi state as boolean
# $1 = Wi-Fi interface name
# $! = Boolean
getWifiState() {
  if [ "$(networksetup -getairportpower "$1" | grep On)" != "" ]; then
    echo 1
  else
    echo 0
  fi
}

# Get ethernet state as boolean
# $1 = Ethernet interface name
# $! = Boolean
getEthernetState() {
  if [ "$1" != "" ]; then
    echo 1
  else
    echo 0
  fi
}

# Get wifi port name
# $1 = networksetup -listallhardwareports
# $! = String
getWifiName() {
  local LIST=${1-$(networksetup -listallhardwareports)}
  local DETAILS=$(echo "$LIST" | grep -A 2 -E "$WIFI_REGEX")
  echo "$DETAILS" | grep -Eo "AirPort|Wi-Fi"
}

# Get ethernet port name
# $1 = networksetup -listallhardwareports
# $! = String
getEthernetName() {
  local LIST=${1-$(networksetup -listallhardwareports)}
  local DETAILS=$(echo "$LIST" | grep -A 2 -E "$ETHERNET_REGEX")
  echo "$DETAILS" | awk '/Hardware / {print substr($0, index($0, $3))}'
}

# Get wifi interface name
# $1 = networksetup -listallhardwareports
# $! = String
getWifiInterface() {
  local LIST=${1-$(networksetup -listallhardwareports)}
  local DETAILS=$(echo "$LIST" | grep -A 2 -E "$WIFI_REGEX")
  echo "$DETAILS" | grep -m 1 -o -e en[0-9]
}

# Get ethernet interface name
# $1 = networksetup -listallhardwareports
# $! = String
getEthernetInterface() {
  local LIST=${1-$(networksetup -listallhardwareports)}
  local DETAILS=$(echo "$LIST" | grep -A 2 -E "$ETHERNET_REGEX")
  echo "$DETAILS" | grep -m 1 -o -e en[0-9]
}

# Get wifi mac address
# $1 = networksetup -listallhardwareports
# $! = String
getWifiMac() {
  local LIST=${1-$(networksetup -listallhardwareports)}
  local DETAILS=$(echo "$LIST" | grep -A 2 -E "$WIFI_REGEX")
  echo "$DETAILS" | awk '/Ethernet Address: / {print substr($0, index($0, $3))}'
}

# Get ethernet mac address
# $1 = networksetup -listallhardwareports
# $! = String
getEthernetMac() {
  local LIST=${1-$(networksetup -listallhardwareports)}
  local DETAILS=$(echo "$LIST" | grep -A 2 -E "$ETHERNET_REGEX")
  echo "$DETAILS" | awk '/Ethernet Address: / {print substr($0, index($0, $3))}'
}

# Find name of primary connected network interface
# $! = String
getPrimaryInterfaceName() {
  local INTERFACE=$(getEthernetInterface)
  if [ $(getEthernetState "$INTERFACE") != 0 ]; then
    echo "$(getEthernetName)"
  else
    echo "$(getWifiName)"
  fi
}

# Extract connection configuration
# $1 = networksetup -getinfo
# $! = String
getConnectionConfig() {
  echo "$1" | grep 'Configuration$'
}

# Extract IP4
# $1 = networksetup -getinfo
# $! = String
getIPv4() {
  echo "$1" | grep '^IP\saddress' \
    | awk '/ address/ {print substr($0, index($0, $3))}'
}

# Extract IP6
# $1 = networksetup -getinfo
# $! = String
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

# Extract SSID
# $1 = airport -getinfo
# $! = String
getSSID() {
  echo "$1" | awk '/ SSID/ {print substr($0, index($0, $2))}'
}

# Pad BSSID
# $1 = BSSID string
# $! = String
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

# Get BSSID
# $1 = airport -getinfo
# $! = String
getBSSID() {
  local BSSID=$(echo "$1" | awk '/ BSSID/ {print substr($0, index($0, $2))}' | xargs)
  # Handle missing BSSID
  if [ "$BSSID" == "BSSID:" ]; then
    echo ""
  else
    echo $(padBSSID "$BSSID")
  fi
}

# Extract wifi authentication
# $1 = airport -getinfo
# $! = String
getAuth() {
  echo "$1" | awk '/ link auth/ {print substr($0, index($0, $2))}'
}

# Resolve global IP
# $1 = Dig resolver address (optional)
# $! = String
getGlobalIP() {
  local RESOLVER=${1:-"myip.opendns.com @resolver1.opendns.com"}

  local IP=$(dig -4 +time=2 +tries=1 +short $RESOLVER)
  if [[ "$IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "$IP"
  fi
}

# Get connected VPN
# $1 = scutil --nc list
# $! = String
getVPN() {
  echo "$1" | awk '/\/*.(Connected)/ {print $7}' | tr -d '"'
}

# Get VPN info
# $1 = `scutil --nc list` lines
# $! = Separated string of VPN info
getVPNInfo() {
  if [[ "$1" =~ \*[[:space:]]\(([a-zA-Z ]*)\)[[:space:]].*\"(.*)\".*\[(.*)\] ]]
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

# Get DNS info
# $1 = `networksetup -getdnsservers <servicename>`
# $! = String
getDNS() {
  if [[ "$1" != *"any DNS"* ]]; then
    echo $1 | sed 's/ / \/ /g'
  else
    echo ""
  fi
}

# Parse DNS info
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

# Get saved access point
# $1 = networksetup -listpreferredwirelessnetworks
# $! = Separated string of saved access points
getSavedAPs() {
  while read -r line; do
    OUTPUT=$OUTPUT~$line
  done <<< "$1"
  echo "${OUTPUT:1}"
}

# Check if list contains an element
# $1 = List of elements
# $2 = Element to check
# $! = Boolean
listContains() {
  while read -r ITEM; do
    if [ "$ITEM" == "$2" ]; then
      echo 1
    fi
  done <<< "$1"
}

# Get WiFi strength
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

# Parse access point details string
# $1 = `airpot --scan` line
# $2 = BSSID or SSID of the active access point (optional)
# $3 = List of favorite access points (optional)
# $! = Separated string of access point settings
getAPDetails() {
  # Example:          SSID BSSID             RSSI CHANNEL HT CC SECURITY
  # Example: "Test-Network 21:aa:4c:b4:cc:11 -24  6       Y  US WPA2(PSK/AES/AES)"
  if [[ "$1" =~ [[:space:]]*(.*)[[:space:]]+([0-9a-f:]{17})?[[:space:]]+(-[0-9]{2})[[:space:]]+([,+0-9]+)[[:space:]]+([YN]{1})[[:space:]]+([-A-Z]{2})[[:space:]]+(.*) ]]
  then
    SSID=$(echo ${BASH_REMATCH[1]} | xargs)
    BSSID=${BASH_REMATCH[2]}
    RSSI=${BASH_REMATCH[3]}
    CHANNEL=${BASH_REMATCH[4]}
    HT=${BASH_REMATCH[5]}
    CC=${BASH_REMATCH[6]}
    SECURITY=$(echo ${BASH_REMATCH[7]} | xargs)
  fi

  FAVORITED=$(listContains "$3" "$SSID")
  PRIORITY=$PRIORITY_LOW

  if [ "$BSSID" != "" ] && [ "$BSSID" == "$2" ] || [ "$SSID" == "$2" ]; then
    AP_ICON=$ICON_WIFI_ACTIVE_
    PRIORITY=$PRIORITY_HIGH
  elif [ "$FAVORITED" != "" ]; then
    AP_ICON=$ICON_WIFI_STAR_
    PRIORITY=$PRIORITY_MEDIUM
  elif [[ "$SECURITY" =~ "NONE" ]]; then
    AP_ICON=$ICON_WIFI_
  else
    AP_ICON=$ICON_WIFI_LOCK_
  fi

  AP_ICON=$AP_ICON$(getWifiStrength "$RSSI")$ICON_END

  if [ "$SSID" != "" ]; then
    echo "$PRIORITY"~"$SSID"~"$BSSID"~"$RSSI"~"$CHANNEL"~"$SECURITY"~"$AP_ICON"  
  fi
}
