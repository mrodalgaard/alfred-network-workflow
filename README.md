# <img src="https://raw.githubusercontent.com/mrodalgaard/alfred-network-workflow/master/icon.png" alt="network" width="32"> Alfred Network Workflow [![Build Status](https://travis-ci.org/mrodalgaard/alfred-network-workflow.svg?branch=master)](https://travis-ci.org/mrodalgaard/alfred-network-workflow)

Alfred workflow that can show and change your network settings: Wi-Fi, Ethernet, VPN, DNS, etc.

This is a collection of the functionalities of already existing network-oriented workflows that I found half-baked or stalled. Improved on performance, usability and details.

## Install

Go to [Latest Release](https://github.com/mrodalgaard/alfred-network-workflow/releases/latest) and under `Assets` download `Network.alfredworkflow`. Once downloaded, double click the file and it will show up in Alfred.

## Usage

* Type `wifi` to show Wi-Fi info and enable/disable.
* Type `eth` to show ethernet info (if connected).
* Type `wifilist` to scan for Wi-Fi hotspots.
* Type `vpn` to list configured VPNs and connect.
* Type `dns` to list and change DNS settings.

<p align="center">
<img src="https://raw.githubusercontent.com/mrodalgaard/alfred-network-workflow/master/screenshots/wifi-preview.png" alt="alfred-wifi-workflow-wifi" width="600">
<img src="https://raw.githubusercontent.com/mrodalgaard/alfred-network-workflow/master/screenshots/wifilist-preview.png" alt="alfred-wifi-workflow-wifilist" width="600">
</p>

Requires Alfred 3 and Powerpack for installing this extension. Might behave differently on macOS versions older than 10.7 Lion. This workflow is primarily implemented in Bash with a little help from AppleScript.

WIFI / Access Point changes requires your keychain password which is a known limitation. See [HERE](https://github.com/mrodalgaard/alfred-network-workflow/issues/11#issuecomment-559252188).

## Tests

[bats](https://github.com/sstephenson/bats) is used for automatic testing of Bash functionality. Install with `brew install bats` using [brew](http://brew.sh/).

Run tests: `bats tests`

## Credits

> Contributions, bug reports and feature requests are very welcome.

> &nbsp; &nbsp; _- Martin_
