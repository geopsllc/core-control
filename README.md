# Core v2 Management Tool

## Installation

```sh
git clone https://github.com/geopsllc/core-control
cd ~/core-control/
./core-control.sh [arguments]
Possible arguments:
install mainnet|devnet
update mainnet|devnet
uninstall mainnet|devnet
start relay|forger|all mainnet|devnet
stop relay|forger|all
```

## General
This is a simple streamlined cli-based core v2 management script. It can install/update/uninstall ark core v2 for both mainnet and 
devnet. It can also start/stop the relay/forger or both. There is a config.conf file that you normally wouldn't need to touch.
It contains coin-specific variables and should only be changed if you plan to use the tool for a non-ARK core v2 chain.

## Changelog

### 0.3
- added mainnet and devnet update procedures

### 0.2
- refactored code with a config file for easy migration to core v2 bridgechains

### 0.1
- initial release

## Security

If you discover a security vulnerability within this package, please open an issue. All security vulnerabilities will be promptly addressed.

## Credits

- [geopsllc](https://github.com/geopsllc)

## License

[MIT](LICENSE) © [geopsllc](https://github.com/geopsllc)
