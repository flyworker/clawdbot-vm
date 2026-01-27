# Clawdbot VM

Automated setup for running [Clawdbot](https://github.com/anthropics/clawdbot) in an isolated Ubuntu VM using Multipass.

## Why a VM?

Running Clawdbot in an isolated VM provides:
- Security isolation from your host system
- Clean environment with controlled dependencies
- Easy teardown and recreation

## Requirements

- Linux or macOS host
- sudo access
- Anthropic API key (or Claude Pro OAuth)

## Quick Start

```bash
# Clone this repo
git clone https://github.com/flyworker/clawdbot-vm.git
cd clawdbot-vm

# Run the installer
./install.sh

# Enter the VM
multipass shell clawdbot

# Complete setup
clawdbot onboard
```

## What the Installer Does

1. **Creates VM** - Ubuntu 22.04 with 2 CPUs, 4GB RAM, 20GB disk
2. **Secures VM** - UFW firewall, fail2ban
3. **Installs dependencies** - 2GB swap, Node.js 22
4. **Installs Clawdbot** - via npm globally
5. **Enables persistence** - user lingering for background services

## VM Management

```bash
# Enter the VM
multipass shell clawdbot

# Stop the VM
multipass stop clawdbot

# Start the VM
multipass start clawdbot

# Delete the VM
multipass delete clawdbot && multipass purge
```

## Configuration

The VM is created with these specs (edit `install.sh` to change):

| Resource | Default |
|----------|---------|
| CPUs | 2 |
| Memory | 4GB |
| Disk | 20GB |
| Swap | 2GB |

## License

MIT
