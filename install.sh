#!/bin/bash
set -e

echo "=== Phase 1: Create VM ==="
sudo snap install multipass
multipass launch 22.04 --name clawdbot --cpus 2 --memory 4G --disk 20G

echo "=== Phase 2-5: Setup inside VM ==="
multipass exec clawdbot -- bash -c '
set -e

echo "--- Updating system ---"
sudo apt update && sudo apt upgrade -y

echo "--- Installing firewall & fail2ban ---"
sudo apt install -y ufw fail2ban
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
sudo apt install -y nodejs

echo "--- Installing Clawdbot ---"
sudo npm install -g clawdbot@latest

echo "--- Enabling service persistence ---"
sudo loginctl enable-linger "$USER"

echo ""
echo "=== Installation complete! ==="
echo "Run: multipass shell clawdbot"
echo "Then: clawdbot onboard"
'
