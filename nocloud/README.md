# Ubuntu 22.04 Automated Install ISO

This project creates a custom ISO image for Ubuntu 22.04 Server that automates the installation process, installs Git and Docker, clones the G-Scan Git Repo, and configures Docker login.

## Requirements

1. A Linux machine/VM (referred to as **BUILDER**) to build the custom image.
2. **BUILDER** must have `xorriso` and `nano` installed.

## Setup Overview

The custom ISO will:
1. Perform a minimal Ubuntu setup installation.
2. Fully automate the installation process.
3. Install Git and Docker.
4. Clone the G-Scan Git Repository and configure Docker login.

## Steps to Create the Custom ISO

### 1. Download Ubuntu 22.04 Server ISO

Download the ISO from the official Ubuntu releases site:

```bash
cd /tmp
wget https://releases.ubuntu.com/jammy/ubuntu-22.04.4-live-server-amd64.iso
```

### 2. Extract ISO Contents

Create a folder to hold the extracted contents and extract the ISO:

```bash
mkdir /tmp/source-files
xorriso -osirrox on -indev ubuntu-22.04.2-live-server-amd64.iso --extract_boot_images source-files/bootpart \
--extract / source-files
```

### 3. Create 'nocloud' Directory and Necessary Files

Create a nocloud directory and required files within the extracted ISO contents:

```bash
cd /tmp/source-files
mkdir -p /tmp/source-files/nocloud
touch /tmp/source-files/nocloud/meta-data
```

Edit the user-data file with the following content:
```bash
touch /tmp/source-files/nocloud/user-data
nano /tmp/source-files/nocloud/user-data
```

Add the following to user-data:
```bash
#cloud-config
autoinstall:
  version: 1
  identity:
    hostname: ubuntu
    password: $6$bnNG20NwjfM3E6m.$hE37w/n.c8ozzotMnXIebcquWJ/HH8mDapBBvYrLyKfLj8Rpu2lzBylBvT9o3o8NQFSJXpHiotu8S/1LzS1GK1
    realname: Rudra
    username: rudra
  keyboard:
    layout: us
  locale: en_US.UTF-8
  timezone: Asia/Kolkata
  network:
    ethernets:
      eth0:
        dhcp4: true
    version: 2
  kernel:
    package: linux-generic
  source:
    id: ubuntu-server-minimal
    search_drivers: false
  ssh:
    allow-pw: true
    authorized-keys: []
    install-server: true
  updates: security
  shutdown: reboot
  late-commands:
    - curtin in-target -- apt-get update
    - curtin in-target -- apt-get install -y vim git
    - curtin in-target -- cp /cdrom/nocloud/setup-gscan.sh /usr/local/bin/
    - curtin in-target -- cp /cdrom/nocloud/firstboot-script /etc/systemd/system/firstboot-script.service
    - curtin in-target -- chmod +x /etc/systemd/system/firstboot-script.service
    - curtin in-target -- chmod +x /usr/local/bin/setup-gscan.sh
    - curtin in-target -- systemctl enable firstboot-script.service
```

### 4. Create setup-gscan.sh Script

Create the setup-gscan.sh script that will install Docker, clone the Git repo, and configure Docker login:
```bash
touch /tmp/source-files/nocloud/setup-gscan.sh
nano /tmp/source-files/nocloud/setup-gscan.sh
```

Add the following content:
```bash
#!/bin/bash

# Add Docker's official GPG key:
apt-get update
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

PAT=your_personal_access_token_here

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
```

### 5. Create firstboot-script Service

Create the firstboot-script service that will run the setup-gscan.sh on first boot:

```bash
touch /tmp/source-files/nocloud/firstboot-script
nano /tmp/source-files/nocloud/firstboot-script
```

Add the following content:
```bash
[Unit]
Description=Run script at first boot
After=network.target

[Service]
ExecStart=/usr/local/bin/setup-gscan.sh
Type=oneshot
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
```

### 6. Modify GRUB Configuration

Edit the GRUB configuration to include a menu entry for automated installation:

```bash
nano /tmp/source-files/boot/grub/grub.cfg
```

Add the following menu entry above the existing one:
```bash
menuentry "Autoinstall Ubuntu Server" {
    set gfxpayload=keep
    linux   /casper/vmlinuz quiet autoinstall ds=nocloud\;s=/cdrom/nocloud/  ---
    initrd  /casper/initrd
}
```
### 7. Repack the ISO

Repack the modified ISO. The resulting ISO will be created under /tmp:
```bash
cd /tmp/source-files
xorriso -as mkisofs -r -V "ubuntu-autoinstall" -J -boot-load-size 4 -boot-info-table -input-charset utf-8 \
-eltorito-alt-boot -b bootpart/eltorito_img1_bios.img -no-emul-boot -o ../installer.iso .
```