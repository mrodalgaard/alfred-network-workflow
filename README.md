# <img src="icon.png" width="32"> Alfred Network Workflow

Alfred workflow that can show and change your network settings.

Requires Alfred 2 and Power Pack for installing this extension. Might behave differently on Mac OSX versions older than 10.7 Lion. This workflow is primarily implemented in bash with a little help from AppleScript.

![alfred-wifi-workflow-wifi](screenshots/wifi-preview.png)

![alfred-wifi-workflow-wifilist](screenshots/wifilist-preview.png)

## Usage

Type `wifi` to show Wi-Fi info and enable/disable.
Type `eth` to show ethernet info (if connected).
Type `wifilist` to scan for Wi-Fi hotspots.
Type `vpn` to list configured VPNs and connect.

## Tests

[bats](https://github.com/sstephenson/bats) is used for automatic testing of bash functionality.

Run tests: `bats tests`

# To Do

- [x] Basic functionality
- [x] Unit tests
- [x] Mark saved networks with a star
- [x] Adjust wifi icon according to strength
- [x] Ethernet support
- [x] VPN list
- [ ] Connect WiFi AP using Applescript
- [ ] Sort APs (improve!)
- [ ] Filter APs on-the-fly, but only scan once
- [ ] Use optional parameters for unit tests
- [ ] Bluetooth list
- [ ] DNS switcher using `networksetup -setdnsservers`
- [ ] Travis CI build

## Credits

> Contributions, bug reports and feature requests are very welcome.

> &nbsp; &nbsp; _- Martin_
