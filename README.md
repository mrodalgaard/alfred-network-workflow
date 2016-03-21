# <img src="https://raw.githubusercontent.com/mrodalgaard/alfred-network-workflow/master/icon.png" alt="network" width="32"> Alfred Network Workflow [![Build Status](https://travis-ci.org/mrodalgaard/alfred-network-workflow.svg?branch=master)](https://travis-ci.org/mrodalgaard/alfred-network-workflow)

Alfred workflow that can show and change your network settings; WiFi, Ethernet, VPN, DNS, etc.

This is a collection of the functionality of already existing network-oriented workflows that I found half-baked or stalled. Improved on performance, usability and details.

Recommended to install via [Packal](http://www.packal.org/workflow/network) for auto update support.

## Usage

* Type `wifi` to show Wi-Fi info and enable/disable.
* Type `eth` to show ethernet info (if connected).
* Type `wifilist` to scan for Wi-Fi hotspots.
* Type `vpn` to list configured VPNs and connect.

<p align="center">
<img src="https://raw.githubusercontent.com/mrodalgaard/alfred-network-workflow/master/screenshots/wifi-preview.png" alt="alfred-wifi-workflow-wifi" width="600">
<img src="https://raw.githubusercontent.com/mrodalgaard/alfred-network-workflow/master/screenshots/wifilist-preview.png" alt="alfred-wifi-workflow-wifilist" width="600">
</p>

Requires Alfred 2 and Power Pack for installing this extension. Might behave differently on Mac OSX versions older than 10.7 Lion. This workflow is primarily implemented in bash with a little help from AppleScript.

## Tests

[bats](https://github.com/sstephenson/bats) is used for automatic testing of bash functionality. Install with `brew install bats` using [brew](http://brew.sh/).

Run tests: `bats tests`

# To Do

- [x] Basic functionality
- [x] Unit tests
- [x] Mark saved networks with a star
- [x] Adjust wifi icon according to strength
- [x] Ethernet support
- [x] VPN list
- [x] Travis CI build
- [ ] Connect WiFi AP using Applescript
- [ ] Sort APs (improve!)
- [ ] Filter APs on-the-fly, but only scan once
- [ ] Use optional parameters for unit tests
- [ ] Bluetooth list
- [ ] DNS switcher using `networksetup -setdnsservers`

## Credits

> Contributions, bug reports and feature requests are very welcome.

> &nbsp; &nbsp; _- Martin_
