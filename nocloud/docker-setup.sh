#!/bin/bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu   $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Get and confirm Git token
get_and_confirm_input "Enter your Git token" git_token

# Get and confirm username
get_and_confirm_input "Enter your username" username

# Store Git token in a variable
PAT=$git_token

# Log in to ghcr.io using Docker
echo $PAT | docker login ghcr.io -u $username --password-stdin

echo "Login completed successfully!"


