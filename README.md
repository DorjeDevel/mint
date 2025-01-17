# Automated Application Installer Scripts for Ubuntu-based Systems

## Overview

This repository contains a collection of Bash scripts designed to automate the installation and configuration of essential applications and services on Ubuntu-based systems. **All scripts should be placed in the directory `~/Downloads/install/` for proper execution.**

### Preparation Steps

1. **Copy the scripts** to the directory `~/Downloads/install/`.
2. **Make the scripts executable**:
   ```bash
   chmod +x ~/Downloads/install/*.sh
   ```
3. Navigate to this directory in the terminal:
   ```bash
   cd ~/Downloads/install/
   ```
4. Run the main script:
   ```bash
   sudo ./MAIN_install.sh
   ```

The `MAIN_install.sh` script will execute all other scripts in sequence, providing a seamless setup process. Additionally, it gives the user the option to create a Timeshift snapshot at the very beginning to ensure system safety before any installations begin.

---

## Scripts Overview

### 1. `MAIN_install.sh`
- The main script that orchestrates the execution of all individual installation scripts.
- Ensures a complete setup of all applications and configurations included in this repository.
- Provides an option to create a Timeshift snapshot at the start of the installation process.

### 2. `install_vnc.sh`
- Installs and configures `x11vnc` as a VNC server.
- Sets up a systemd service to run the VNC server on startup.
- Secures the VNC server with a password (8 characters or fewer).

### 3. `install_enpass.sh`
- Automates the installation of Enpass password manager.
- Adds the official Enpass repository and GPG key.

### 4. `install_nordvpn.sh`
- Installs NordVPN using the official NordVPN setup script.
- Configures subnet whitelisting for VNC server access when VPN is active.
- Includes pre-configured scripts for:
  - Connecting to servers in Austria and Switzerland.
  - Disconnecting from NordVPN and checking connection status.
- Creates desktop shortcuts for easy management.

### 5. `install_pcloud.sh`
- Downloads and installs the pCloud desktop client.
- Configures pCloud to start on system boot.
- Provides instructions for updating the download URL if it changes.

### 6. `install_media.sh`
- Installs MediathekView ([mediathekview.de](https://mediathekview.de)) along with multimedia tools `vlc` and `ffmpeg` for media playback and processing.
- Verifies successful installation by checking installed versions.

---

## Prerequisites
- Developed for Linux Mint Cinnamon 22.
- Root or `sudo` access.
- `timeshift` installed for creating system snapshots.

---

## Usage

### Cloning the Repository
```bash
git clone https://github.com/DorjeDevel/mint.git
cd mint
```

### Preparing the Scripts
1. Copy all scripts to the `~/Downloads/install/` directory.
2. Make all scripts executable:
   ```bash
   chmod +x ~/Downloads/install/*.sh
   ```
3. Navigate to this directory in the terminal:
   ```bash
   cd ~/Downloads/install/
   ```

### Running the Main Script
Run the main script to install and configure all applications:
```bash
sudo ./MAIN_install.sh
```

---

## Notes
- **Timeshift Snapshots**: The main script provides an option to create a single snapshot at the beginning of the installation process. This ensures the system can be restored to its initial state if needed.
- **NordVPN Login**: After installation, log in using:
  ```bash
  nordvpn login
  ```
- **Updating pCloud URL**: If the download URL changes, update it in the `install_pcloud.sh` script as per the included comments.

---

## Troubleshooting
- Verify Timeshift snapshots if you encounter issues.
- Ensure active network connectivity during installation.
- Check file permissions to ensure scripts are executable.

---

## License
This repository is licensed under the [MIT License](LICENSE). Use at your own risk.

---

## Disclaimer
These scripts are provided "as-is" without warranty. Users are advised to review and test them before deploying on critical systems.

