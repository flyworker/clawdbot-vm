# OpenClaw VM

Automated setup for running [OpenClaw](https://docs.openclaw.ai/) in an isolated Ubuntu VM using Multipass.

## Why a VM?

Running OpenClaw in an isolated VM provides:
- Security isolation from your host system
- Clean environment with controlled dependencies
- Easy teardown and recreation

## Requirements

- Linux or macOS host
- sudo access
- LLM API key (Anthropic, MegaNova, or other OpenAI-compatible provider)

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
openclaw onboard
```

## What the Installer Does

1. **Creates VM** - Ubuntu 22.04 with 2 CPUs, 4GB RAM, 20GB disk
2. **Secures VM** - UFW firewall, fail2ban
3. **Installs dependencies** - 2GB swap, Node.js 22
4. **Installs OpenClaw** - via npm globally
5. **Enables persistence** - user lingering for background services

## VM Management

```bash
# Enter the VM
multipass shell clawdbot

# Update OpenClaw (inside the VM)
sudo npm install -g openclaw@latest

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

## LLM Providers

OpenClaw supports multiple LLM providers including Anthropic, MegaNova, and local models via Ollama. See [docs/providers.md](docs/providers.md) for setup instructions.

## Security

For details on why VM isolation matters and the security measures included, see [docs/security.md](docs/security.md).

## License

MIT
