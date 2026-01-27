# Clawdbot VM Installation Plan

## Overview
Install Clawdbot in an isolated Ubuntu VM for security.

## Quick Start
```bash
./install.sh
```

## Steps

### Phase 1: Create VM
- [ ] Install multipass
- [ ] Launch Ubuntu 22.04 VM (2 CPU, 4GB RAM, 20GB disk)

### Phase 2: Secure the VM
- [ ] Update system packages
- [ ] Install and configure UFW firewall
- [ ] Install and enable fail2ban

### Phase 3: Install Dependencies
- [ ] Add swap file (2GB)
- [ ] Install Node.js 22

### Phase 4: Install Clawdbot
- [ ] Install clawdbot via npm
- [ ] Run onboard wizard (requires API key)

### Phase 5: Configure Service
- [ ] Enable user lingering
- [ ] Enable clawdbot-gateway service

## Requirements
- Anthropic API key (or OpenAI/Claude Pro OAuth)
- sudo access on host machine
