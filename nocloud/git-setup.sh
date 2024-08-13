#!/bin/bash

# Function to get and confirm input
get_and_confirm_input() {
  local prompt="$1"
  local var_name="$2"
  while true; do
    read -p "$prompt: " input
    read -p "You entered '$input'. Is this correct? (y/n) " confirm
    if [[ $confirm == [Yy]* ]]; then
      eval "$var_name='$input'"
      break
    fi
  done
}

# Get and confirm Git token
get_and_confirm_input "Enter your Git token" git_token

# Get and confirm repository name
get_and_confirm_input "Enter the repository name" repo_name

# Get and confirm user's full name
get_and_confirm_input "Enter your full name" user_full_name

# Get and confirm user's email address
get_and_confirm_input "Enter your email address" user_email

# Construct the Git URL
git_url="https://$git_token@github.com/spacenoxxx/$repo_name"
echo "Cloning repository from $git_url..."

# Clone the repository
git clone "$git_url"

# Making user rudra owner of the folder
chown -R rudra:rudra $repo_name

# Configure Git user details
echo "Configuring Git user details..."
cd $repo_name
git config --global user.name "$user_full_name"
git config --global user.email "$user_email"

echo "Setup completed successfully!"
