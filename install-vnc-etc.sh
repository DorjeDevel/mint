#!/bin/sh

## ########################################################################################################
##   Script Name: install-vnc-etc.sh
##   Author: DorjeDevel
##   Date: 2025-01-15
##   Purpose: Install VNC, NordVPN, Enpass, pCloud, Mediathekview and related dependencies.
##
##   RUN THIS SCRIPT AS SUDO.
##
## ########################################################################################################

# RUN THIS SCRIPT AS SUDO.
# Check if the script is run as root (with sudo)
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run with sudo."
  echo "Please run it using: sudo $0"
  exit 1
fi


echo
echo "## ########################################################################################################"
echo "##"
echo "##   Checking if there is another process of this script running..."
echo "##"
echo "## ########################################################################################################"
echo

LOCKFILE="/var/lock/install-vnc-etc.lock"

# Check if the script is already running
if [ -e "$LOCKFILE" ]; then
  echo "Another instance of this script is already running."
  exit 1
fi

# Create a lock file to prevent multiple instances
touch "$LOCKFILE"

# Ensure the lock file is removed when the script exits
trap 'rm -f "$LOCKFILE"' EXIT




echo
echo "## ########################################################################################################"
echo "##"
echo "##   Checking if Timeshift is running..."
echo "##"
echo "## ########################################################################################################"
echo

TIMESHIFT_PID=$(pgrep timeshift)

if [ -n "$TIMESHIFT_PID" ]; then
  echo "Timeshift is running with PID $TIMESHIFT_PID. Checking status..."
  
  # Check if Timeshift is actively creating a snapshot
  if ps -p "$TIMESHIFT_PID" -o args= | grep -q "snapshot"; then
    echo "Timeshift is currently creating a snapshot. Waiting for it to finish."
    while ps -p "$TIMESHIFT_PID" -o args= | grep -q "snapshot"; do
      sleep 5
    done
    echo "Snapshot creation completed. Proceeding..."
  else
    echo "Timeshift is running but idle. Terminating process..."
    kill "$TIMESHIFT_PID"
    echo "Timeshift process terminated."
  fi
else
  echo "Timeshift is not running. Proceeding..."
fi





# --------------------------------------------------------------------------------------------------------
#   Make a Timeshift Snapshot
# --------------------------------------------------------------------------------------------------------

timeshift --create --comments "Before executing sctipt install-vnc-etc.sh" --tags D



echo
echo "## ########################################################################################################"
echo "##"
echo "##   Installing VNC..."
echo "##"
      ##   This part of the script was copied from 
      ##   https://github.com/axrusar/vnc-server-installer/blob/main/vnc-server-setup.sh
      ##   and edited by DorjeDevel.
      ##
echo "## ########################################################################################################"


## Wait for VNC password prompt and confirmations

echo
echo "$(tput setaf 3)  Welcome to the automated VNC server installer script by axrusar :)."
echo "  This basic script should work on Ubuntu based systems"
echo "  Please wait for the prompts. Your VNC password can only be 8 characters or less,"
echo "  otherwise it will get truncated."
echo "  Select Y (default option) when prompted to store the password"
echo

read -p "Press ENTER to continue" </dev/tty

apt update
apt install x11vnc -y

mkdir /etc/x11vnc
x11vnc --storepasswd /etc/x11vnc/vncpwd
touch /lib/systemd/system/x11vnc.service

cat > /lib/systemd/system/x11vnc.service << EOL
[Unit]
Description=Start x11vnc at startup.
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -auth guess -forever -noxdamage -repeat -rfbauth /etc/x11vnc/vncpwd -rfbport 5900 -shared

[Install]
WantedBy=multi-user.target
EOL

systemctl daemon-reload
systemctl enable x11vnc.service
systemctl start x11vnc
echo ""
echo ""
echo "$(tput setaf 3)VNC installed and running."


# --------------------------------------------------------------------------------------------------------
#   Make a Timeshift Snapshot
# --------------------------------------------------------------------------------------------------------
timeshift --create --comments "VNC installed" --tags D



echo
echo "## ########################################################################################################"
echo "##"
echo "##   Installing Enpass..."
      ##   https://support.enpass.io/app/getting_started/installing_enpass.htm
echo "##"
echo "## ########################################################################################################"

# add a new repository to /etc/apt/sources.list
echo "deb https://apt.enpass.io/ stable main" | sudo tee /etc/apt/sources.list.d/enpass.list

# Import key that is used to sign the release
wget -O - https://apt.enpass.io/keys/enpass-linux.key | sudo tee /etc/apt/trusted.gpg.d/enpass.asc

# After that, you can install Enpass as any other software package:
apt-get update
apt-get install enpass


# --------------------------------------------------------------------------------------------------------
#   Make a Timeshift Snapshot
# --------------------------------------------------------------------------------------------------------
timeshift --create --comments "Enpass installed" --tags D



echo
echo "## ########################################################################################################"
echo "##"
echo "##   Installing NordVPN..."
      ##   https://nordvpn.com/download/linux/#install-nordvpn
echo "##"
echo "## ########################################################################################################"

# Install the app
sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)

# Check if user is in 'nordvpn' group
if groups $USER | grep -qw "nordvpn"; then
  echo "User is already in the 'nordvpn' group. Skipping group modification step."
else
  # Benutzer zur Gruppe hinzufügen
  usermod -aG nordvpn $USER
  echo "User has been added to the 'nordvpn' group. Please reboot your system to apply the changes."
  exit 1
fi

# add subnet to NordVPN to make sure VNC connect while VPN is running 

# collect IP address and subnetz mask
CURRENT_IP=$(ip -o -f inet addr show | awk '/scope global/ {print $4}')

# set to subnet
if [[ -n "$CURRENT_IP" ]]; then
  BASE_IP=$(echo "$CURRENT_IP" | sed -E 's/([0-9]+\.[0-9]+\.[0-9]+)\.[0-9]+\/([0-9]+)/\1.0\/\2/')
  
  echo "Your subnetz-IP: $BASE_IP"

  # add subnet to NordVPN
  nordvpn whitelist add subnet "$BASE_IP"
else
  echo "Error: Couldn't find IP!"
  exit 1
fi


echo "After NordVPN is installed reboot your computer and log in to your NordVPN account:"
echo "> reboot"
echo "> nordvpn login"
echo 
echo "Then connect to a VPN server:"
echo "> nordvpn connect"
echo "or "
echo "> nordvpn connect Austria"
echo "> nordvpn connect Switzerland"
echo 
echo "Disconnect VPN with:"
echo "> nordvpn disconnect"
echo
echo "Check VPN status with: "
echo "> nordvpn status"
echo

## #############################
##   Make some NordVPN files  ##
## #############################

# Determine the original user
USER_HOME=$(eval echo ~${SUDO_USER})

# Create the directory if it doesn't exist
if [ ! -d "$USER_HOME/NordVPN" ]; then
  mkdir -p "$USER_HOME/NordVPN"
fi

echo "Creating some helpful script files, to handle with NordVPN..."

# Connect to Austria
echo "Creating 'NordVPN-AUSTRIA.sh'..."
echo '#!/bin/sh
nordvpn connect Austria' > "$USER_HOME/NordVPN/NordVPN-AUSTRIA.sh"

# Adjust ownership and permissions
chown "$SUDO_USER:$SUDO_USER" "$USER_HOME/NordVPN/NordVPN-AUSTRIA.sh"
chmod +x "$USER_HOME/NordVPN/NordVPN-AUSTRIA.sh"

# ------------------------------

# Create to Switzerland
echo "Creating 'NordVPN-SWISS.sh'..."
echo '#!/bin/sh
nordvpn connect Switzerland' > "$USER_HOME/NordVPN/NordVPN-SWISS.sh"

# Adjust ownership and permissions
chown "$SUDO_USER:$SUDO_USER" "$USER_HOME/NordVPN/NordVPN-SWISS.sh"
chmod +x "$USER_HOME/NordVPN/NordVPN-SWISS.sh"

# ------------------------------

# Create the script file
echo "Creating 'NordVPN-DISCONNECT.sh'..."
echo '#!/bin/sh
nordvpn disconnect' > "$USER_HOME/NordVPN/NordVPN-DISCONNECT.sh"

# Adjust ownership and permissions
chown "$SUDO_USER:$SUDO_USER" "$USER_HOME/NordVPN/NordVPN-DISCONNECT.sh"
chmod +x "$USER_HOME/NordVPN/NordVPN-DISCONNECT.sh"

# ------------------------------

# Create the script file
echo "Creating 'NordVPN-STATUS.sh'..."
echo '#!/bin/sh
nordvpn disconnect' > "$USER_HOME/NordVPN/NordVPN-STATUS.sh"

# Adjust ownership and permissions
chown "$SUDO_USER:$SUDO_USER" "$USER_HOME/NordVPN/NordVPN-STATUS.sh"
chmod +x "$USER_HOME/NordVPN/NordVPN-STATUS.sh"

# ------------------------------

# Create the script file
echo "Creating 'Run STATUS.desktop'..."
echo '[Desktop Entry]
Type=Application
Terminal=true
Name=Run Script
Exec=/bin/sh /home/avo/Schreibtisch/NordVPN-STATUS.sh
Icon=utilities-terminal
Name[de_DE]=Run STATUS' > "$USER_HOME/NordVPN/Run STATUS.desktop"

# Adjust ownership and permissions
chown "$SUDO_USER:$SUDO_USER" "$USER_HOME/NordVPN/Run STATUS.desktop"
chmod +x "$USER_HOME/NordVPN/Run STATUS.desktop"

echo "Ready."
echo "You can find the files in the created NordVPN folder."
echo "The 'Run STATUS.desktop' is running the 'NordVPN-STATUS.sh' without asking for permission."

# --------------------------------------------------------------------------------------------------------
#   Make a Timeshift Snapshot
# --------------------------------------------------------------------------------------------------------
timeshift --create --comments "NordVPN installed" --tags D



echo
echo "## ########################################################################################################"
echo "##"
echo "##   Installing pCloud..."
echo "##"
      ##   Original script from:
      ##   https://surajdeshpande.wordpress.com/2021/01/18/upgrade-pcloud-version-on-ubuntu-using-shell-script/
      ##   
      ##   Updated and extended by DorjeDevel
      ##   Version: 2025-01-16 
      ##   
      ##   The web browser URL for downloading the pcloud app is
      ##   https://www.pcloud.com/how-to-install-pcloud-drive-linux.html?download=electron-64
      ##   but wget or curl wont find the right file but instead would download the web page.
      ##   You have to check with F12 in browser (choose network > Media and click on the GET line "p-lux1.cloud.com") 
      ##   to see the correct URL in the file-headers area on the right side of the F12-dev-window.
      ##
echo "## ########################################################################################################"

# Determine the original user and their home directory
USER_HOME=$(eval echo ~${SUDO_USER:-$USER})
EXEC_USER=${SUDO_USER:-$USER}

# Check system architecture (64-bit only)
if [ "$(uname -m)" != "x86_64" ]; then
  echo "This script supports only 64-bit systems."
  exit 1
fi

# Change directory to downloads folder
echo 'Jumping to Downloads...'
cd "/home/$EXEC_USER/Downloads" || { echo "Error: Unable to access Downloads folder."; exit 1; }
pwd
echo

# Delete existing pcloud file
echo "Removing existing pcloud file in Downloads..."
rm -f pcloud
echo

# URL of the file
url="https://p-lux1.pcloud.com/cBZOomEB3Zd6YO7b7ZZZGriWXkZ2ZZa55ZkZ9U8xVZz8ZTzZSYZpRZz4Z1pZnLZdQZpQZEQZGQZyzZU8ZYQZxqNX5ZbYH5fYNIg0Q9UsLkb78hpy1gpDzk/pcloud"

# Target file name
output_file="pcloud"

# Minimum size in bytes (50 MB = 50 * 1024 * 1024)
min_size=$((50 * 1024 * 1024))

# Download the file
echo "Downloading file..."
wget "$url" -O "$output_file"

# Check if the download was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to download the file."
  exit 1
fi

# Get the size of the downloaded file
file_size=$(stat -c%s "$output_file")

# Display the file size
echo "File size: $file_size bytes"

# Check the size
if [ "$file_size" -ge "$min_size" ]; then
  # File is large enough. Proceeding with the script.

  # Allow executing file as a program
  echo 'Making file executable...'
  chmod +x pcloud || { echo "Error: Failed to make the file executable."; exit 1; }

  # Kill existing pcloud processes
  echo 'Killing existing pcloud processes...'
  pgrep -u $EXEC_USER -f pcloud | xargs -r kill -9

  # Copy updated version to bin folder
  echo 'Copying updated version to bin folder...'
  sudo cp pcloud /usr/bin/ || { echo "Error: Failed to copy pcloud to /usr/bin."; exit 1; }
  echo 
  echo 'Starting pCloud...'
  nohup pcloud > "$HOME/.pcloud.log" 2>&1 &

  # Add pcloud to autostart

  # Make sure autostart directory exists
  mkdir -p "$HOME/.config/autostart" || { echo "Error: Unable to create autostart directory."; exit 1; }

  # Create autostart entry
  autostart_file="$HOME/.config/autostart/pcloud.desktop"
  echo "[Desktop Entry]" > "$autostart_file"
  echo "Type=Application" >> "$autostart_file"
  echo "Exec=/usr/bin/pcloud" >> "$autostart_file"  # Updated path
  echo "Hidden=false" >> "$autostart_file"
  echo "NoDisplay=false" >> "$autostart_file"
  echo "X-GNOME-Autostart-enabled=true" >> "$autostart_file"
  echo "Name=pCloud" >> "$autostart_file"
  echo "Comment=Start pCloud at login" >> "$autostart_file"

  echo "pCloud has been added to autostart."

  # Set correct ownership for the user
  chown "$EXEC_USER:$EXEC_USER" "$USER_HOME/Downloads/pcloud"
  chown -R "$EXEC_USER:$EXEC_USER" "$USER_HOME/.config/autostart"

  echo "Installation complete. pCloud has been added to startup and should now be running."
else
  # File size is too small to be the pcloud app
  echo "File is too small. Deleting file..."
  echo "Please check the download URL in this script as it seems to have changed. There is a small how-to in the comment."
  rm "$output_file"
fi

# Wait for User to return
echo "Press ENTER key to continue..."
read




# --------------------------------------------------------------------------------------------------------
#   Make a Timeshift Snapshot
# --------------------------------------------------------------------------------------------------------
timeshift --create --comments "pCloud installed and added to autostart" --tags D




echo
echo "## ########################################################################################################"
echo "##"
echo "##   Installing Mediathekview, VLC and ffmpeg..."
echo "##"
echo "## ########################################################################################################"

#!/bin/bash

# Update the package list
echo "Updating package list..."
sudo apt update

# Upgrade the system
echo "Upgrading system packages..."
sudo apt upgrade -y

# Install VLC
echo "Installing VLC..."
sudo apt install -y vlc

# Install FFmpeg
echo "Installing FFmpeg..."
sudo apt install -y ffmpeg

# Verify installations
echo "Checking installed versions..."
vlc_version=$(vlc --version 2>/dev/null | head -n 1)
ffmpeg_version=$(ffmpeg -version 2>/dev/null | head -n 1)

echo "Installed Versions:"
echo "VLC: ${vlc_version:-Not Installed}"
echo "FFmpeg: ${ffmpeg_version:-Not Installed}"
echo

echo
echo "## ########################################################################################################"
echo "##"
echo "##   Script complete!"
echo "##   Please check the output above!"
echo "##"
echo "##   Have Fun!"
echo "##"
echo "## ########################################################################################################"
echo



