# Ubuntu 22.04 Automated Install ISO

This project creates a custom ISO image for Ubuntu 22.04 Server that automates the installation process, installs Git and Docker, clones the G-Scan Git Repo, and configures Docker login.

## Requirements

1. A Linux machine/VM (referred to as **BUILDER**) to build the custom image.
2. **BUILDER** must have `xorriso` installed.

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
xorriso -osirrox on -indev /tmp/ubuntu-22.04.4-live-server-amd64.iso --extract_boot_images /tmp/source-files/bootpart -extract / /tmp/source-files
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



