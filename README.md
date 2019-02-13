# Core v2 Management Tool - Ark Mainnet

## Installation

```sh
git clone https://github.com/geopsllc/core-control
cd core-control
./ccontrol.sh arg1 [arg2]
```

| arg1 | arg2 | Description |
| --- | --- | --- |
| `install` | `core` | Install Core |
| `update` | `core`/`self`/`check` | Update Core / Core-Control / Check |
| `remove` | `core`/`self` | Remove Core / Core-Control |
| `secret` | `set`/`clear` | Delegate Secret Set / Clear |
| `start` | `relay`/`forger`/`all` | Start Core Services |
| `restart` | `relay`/`forger`/`all` | Restart Core Services |
| `stop` | `relay`/`forger`/`all` | Stop Core Services |
| `status` | `relay`/`forger`/`all` | Show Core Services Status |
| `logs` | `relay`/`forger`/`all` | Show Core Logs |
| `snapshot` | `create`/`restore` | Snapshot Create / Restore |
| `system` | `info`/`update` | System Info / Update |
| `config` | `reset` | Reset Config Files to Defaults |

## General
This is a Streamlined CLI-Based Core v2 Management Tool. 
- Installs fail2ban for ssh, and ufw allowing only port 22(ssh) and the cores ports.
- For start/restart/stop/status/logs you can skip the 'all' argument as it's the default.
- For install/remove you can skip the 'core' argument as it's the default.
- For update you can skip the 'check' argument as it's the default.
- For system you can skip the 'info' argument as it's the default.
- When setting a delegate secret just paste your secret after the 'set' argument without quotes.
- The snapshot is stored in the 'snapshots' folder in your home directory using the database name, e.g. ark_mainnet. 
If you're using an external snapshot make sure to rename it accordingly and put it in the 'snapshots' folder.
- Running with the 'remove' argument does not delete the 'snapshots' folder or the stored snapshot in order to allow you
to take a snapshot, do remove/install and restore it afterwards.
- The script adds an alias named 'ccontrol' on first run. On your next shell login you'll be able to call the script from anywhere
using: ccontrol arg1 [arg2]. It also has autocomplete functionality for all possible arguments.
- Using the 'config reset' arguments will stop the core processes, delete your existing configs and replace them with the defaults.
If you're running a forger and/or have custom settings, you should add them again.
- Do not run as root!

## Changelog

### 2.1
- bump version to match core major version
- added status argument to show process status

### 0.7
- added a splash of color
- added update check to show update availability
- the ccontrol alias now has autocomplete for all arguments
- refactored some operations for consistency
- core remove is now done with 'remove core'
- added self-remove as an otion with 'remove self'
- moved miscellaneous variables and checks to misc.sh
- core update is now done with 'update core'
- added self-update as an otion with 'update self'
- removed automatic self-update

### 0.6
- added delegate secret management
- added local snapshot management
- added process restart capability
- automatically adds alias 'ccontrol' on first run
- standardize the script name and alias to 'ccontrol'
- added hostname and IP data to system info
- Made error messages easier to understand
- added config reset capability

### 0.5
- added system update
- added logs display
- network name is now pulled from .env for simpler commands
- renamed main script to cc.sh
- added devbranch variable to project.conf
- added automatic tool update from git
- renamed uninstall to remove
- added fail2ban (with default ssh protection)
- added ufw with configuration for ssh and the core ports in use
- reconfigure sshd_config with PermitRootLogin prohibit-password
- added pm2 logrotate module
- pm2 now starts on boot and saves process state after start/stop

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

- [All Contributors](../../contributors)
- [Georgi Stoyanov](https://github.com/geopsllc)

## License

[MIT](LICENSE) © [geopsllc](https://github.com/geopsllc)
