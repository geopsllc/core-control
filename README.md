# Core v2 Management Tool

## Installation

```sh
git clone https://github.com/geopsllc/core-control
cd ~/core-control
./cc.sh argument1 [argument2]
Possible arguments:
install mainnet|devnet (Install Core)
update (Update Core)
remove (Uninstall Core)
start relay|forger|all (Start Core Services)
stop relay|forger|all (Stop Core Services)
system update (Run System Update)
system (Show System Information)
```

## General
This is a simple streamlined cli-based core v2 management script. It can install/update/remove ark core v2 for both mainnet and 
devnet. It can also start/stop the relay/forger or both. There is a config.conf file that you normally wouldn't need to touch.
It contains coin-specific variables and should only be changed if you plan to use the tool for a non-ARK core v2 chain.
Using the "system" argument will now show you system information. Using "system update" will perform a system dist-upgrade.

## Changelog

### 0.5
- added sustem update
- network name is now pulled from .env for simpler commands
- renamed main script to cc.sh
- added devbranch variable in config.conf
- added automatic tool update from git
- renamed uninstall to remove

### 0.4
- added system information

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
