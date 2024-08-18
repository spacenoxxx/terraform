#!/bin/bash

# Add Docker's official GPG key:
apt-get update
apt install -y language-pack-en
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

PAT=<insert_your_PAT_here>

# setup git
git_url="https://$PAT@github.com/GridSentry-Pvt-Ltd/G-Scan-Deployment"
echo "Cloning repository from https://github.com/GridSentry-Pvt-Ltd/G-Scan-Deployment ..."

# Clone the repository
cd /home/rudra
git clone "$git_url"
chown -R rudra:rudra G-Scan-Deployment 
cd G-Scan-Deployment
echo $PAT | docker login ghcr.io -u Gridsentry-cyber --password-stdin
docker compose up -d


