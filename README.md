# Automated VNC Server and Application Installer Script

## Overview

This repository provides a comprehensive Bash script for automating the installation of essential applications on Ubuntu-based systems. The script includes:

- VNC server setup
- Installation of Enpass
- NordVPN configuration
- pCloud installation and setup
- MediathekView with VLC and FFmpeg

Each installation step is automated and includes pre- and post-installation Timeshift snapshots to ensure system integrity.

---

## Features

### 1. VNC Server Setup
- Installs and configures `x11vnc`.
- Creates a systemd service to run the VNC server on startup.
- Ensures secure password storage for the VNC server.
- Includes Timeshift snapshots before and after installation.

### 2. Enpass Installation
- Adds the official Enpass repository and GPG key.
- Installs Enpass password manager.
- Takes Timeshift snapshots to save system state.

### 3. NordVPN Setup
- Automates NordVPN installation using the official NordVPN script.
- Configures subnet whitelisting for VNC server access during VPN use.
- Provides pre-configured scripts for:
  - Connecting to Austria and Switzerland servers.
  - Disconnecting and checking NordVPN status.
- Creates desktop shortcuts for easy access.
- Includes Timeshift snapshots.

### 4. pCloud Installation
- Automates pCloud download, installation, and setup.
- Adds pCloud to system startup.
- Provides instructions to handle potential URL changes for downloading the application.
- Includes Timeshift snapshots.

### 5. MediathekView and Multimedia Tools
- Installs `vlc` and `ffmpeg` for media playback and processing.
- Verifies the installation by displaying installed versions.

---

## Prerequisites
- Ubuntu-based system.
- Root or `sudo` access to execute the script.
- Ensure `timeshift` is installed for system snapshots.

---

## Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/automated-installer.git
   cd automated-installer
   ```

2. Make the script executable:
   ```bash
   chmod +x install-vnc-etc.sh
   ```

3. Run the script as `sudo`:
   ```bash
   sudo ./install-vnc-etc.sh
   ```

4. Follow the on-screen prompts for additional configurations.

---

## Notes
- **VNC Password**: The password for `x11vnc` must be 8 characters or fewer.
- **NordVPN**: Reboot the system after installing NordVPN and login using:
  ```bash
  nordvpn login
  ```
- **pCloud**: If the download URL changes, refer to the comment in the script for instructions on updating the URL.

---

## Troubleshooting
- Check the Timeshift snapshots if you encounter issues.
- Ensure network connectivity for downloading application files.
- Verify that you have sufficient permissions to execute the script.

---

## Disclaimer
This script is provided "as-is" without warranty. Use at your own risk.

---

## License
[MIT License](LICENSE)

