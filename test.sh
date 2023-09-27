#!/bin/bash

. src/helpers.sh

NAME="$(getPrimaryInterfaceName)"
echo $NAME

DNSSTRING=$(getDNS "$(networksetup -getdnsservers "$NAME")")
echo $DNSSTRING
