#!/bin/bash
set -e

echo "=== Phase 1: Install & Configure Multipass ==="

# Install multipass if not present
if ! command -v multipass &> /dev/null; then
    echo "--- Installing multipass ---"
    sudo snap install multipass
    sleep 2
fi

# Check if authentication is needed
if ! multipass list &> /dev/null; then
    echo "--- Setting up multipass authentication ---"
    echo "You need to set a passphrase for multipass."
    sudo multipass set local.passphrase
    echo ""
    echo "Now authenticate with the passphrase you just set:"
    multipass authenticate
fi

echo "=== Phase 2: Create VM ==="

# Check if VM already exists
if multipass list | grep -q "clawdbot"; then
    echo "VM 'clawdbot' already exists. Delete it first with:"
    echo "  multipass delete clawdbot && multipass purge"
    exit 1
fi

multipass launch 22.04 --name clawdbot --cpus 2 --memory 4G --disk 20G

echo "=== Phase 3: Setup inside VM ==="
multipass exec clawdbot -- bash -c '
set -e

# Disable interactive prompts for service restarts
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
sudo sed -i "s/#\$nrconf{restart} = .*/\$nrconf{restart} = '"'"'a'"'"';/" /etc/needrestart/needrestart.conf 2>/dev/null || true

echo "--- Updating system ---"
sudo apt update && sudo apt upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

echo "--- Installing firewall & fail2ban ---"
sudo DEBIAN_FRONTEND=noninteractive apt install -y ufw fail2ban
sudo ufw default deny incoming
sudo ufw allow ssh
sudo ufw --force enable
sudo systemctl enable --now fail2ban

echo "--- Creating swap file ---"
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab

echo "--- Installing Node.js 22 ---"
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo DEBIAN_FRONTEND=noninteractive apt install -y nodejs

echo "--- Installing Clawdbot ---"
sudo npm install -g clawdbot@latest

echo "--- Enabling service persistence ---"
sudo loginctl enable-linger "$USER"

echo ""
echo "=== Installation complete! ==="
echo "Run: multipass shell clawdbot"
echo "Then: clawdbot onboard"
'
