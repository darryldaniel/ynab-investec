#!/usr/bin/env bash

set -e

if [ -z "$CLOUDFLARE_TOKEN" ]; then
  echo "Please set CLOUDFLARE_TOKEN to continue"
  exit 1
fi

# Update the system
sudo apt-get update && sudo apt-get upgrade -y

echo "🐳 Install Docker"

# Remove old conflicting packages
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Setup the apt repository
# Add Docker's official GPG key:
sudo apt-get update && \
    sudo apt-get install ca-certificates curl && \
    sudo install -m 0755 -d /etc/apt/keyrings && \
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
    sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    sudo apt-get update

# Install Docker
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Allow docker to run without sudo
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker # activates the changes immediately

echo "✅ Done!"

echo "🕳️ Install Cloudflare Tunnel"
# Add cloudflare gpg key
sudo mkdir -p --mode=0755 /usr/share/keyrings && \
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Add this repo to your apt repositories
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' \
    | sudo tee /etc/apt/sources.list.d/cloudflared.list

# install cloudflared
sudo apt-get update && sudo apt-get install cloudflared -y

# Run the tunnel
sudo cloudflared service install $CLOUDFLARE_TOKEN

# Add ynab-investec.darryldaniel.dev to hosts file
echo "127.0.0.1     ynab-investec.darryldaniel.dev" | sudo tee -a /etc/hosts > /dev/null

echo "✅ Done!"

