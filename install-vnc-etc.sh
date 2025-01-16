#!/bin/bash

## ########################################################################################################
##
##   VNC Part copied from https://github.com/axrusar/vnc-server-installer/blob/main/vnc-server-setup.sh
##
## ########################################################################################################

# --------------------------------------------------------------------------------------------------------
#   Make a Timeshift Snapshot
# --------------------------------------------------------------------------------------------------------

timeshift --create --comments "Vor Start des Sktipts install-vnc-etc.sh" --tags D




## ########################################################################################################
##
##   Install VNC
##
## ########################################################################################################


## RUN THIS SCRIPT AS SUDO.
## Wait for VNC password prompt and confirmations

echo "$(tput setaf 3)  Welcome to the automated VNC server installer script by axrusar :)."
echo "  This basic script should work on Ubuntu based systems"
echo "  Please wait for the prompts. Your VNC password can only be 8 characters or less,"
echo "  otherwise it will get truncated."
echo "  Select Y (default option) when prompted to store the password"

read -p "Press Enter to continue" </dev/tty

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
echo "$(tput setaf 3)VNC installed and running, you can close this window"


# --------------------------------------------------------------------------------------------------------
#   Make a Timeshift Snapshot
# --------------------------------------------------------------------------------------------------------
timeshift --create --comments "VNC installed" --tags D




## ########################################################################################################
##
##   Install Enpass
##   https://support.enpass.io/app/getting_started/installing_enpass.htm
##
## ########################################################################################################

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



## ########################################################################################################
##
##   Install NordVPN 
##   https://nordvpn.com/download/linux/#install-nordvpn
##
## ########################################################################################################

# Install the app
sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)

# Extra Step (weil sonst nach dem nächsten Schritt Fehlermeldung)
usermod -aG nordvpn $USER

# After Instalation make a reboot and log in to your account
# > reboot
# > nordvpn login
# 
# Then connect to a server
# > nordvpn connect
# or 
# > nordvpn connect Austria
# or
# > nordvpn connect Switzerland
# 
# Disconnect
# > nordvpn disconnect
#
# See Status
# > nordvpn status


## #############################
##   Make some NordVPN files  ##
## #############################

# Determine the original user
USER_HOME=$(eval echo ~${SUDO_USER})

# Create the directory if it doesn't exist
if [ ! -d "$USER_HOME/NordVPN" ]; then
  mkdir -p "$USER_HOME/NordVPN"
fi

# ------------------------------

# Create the script file
cat >"$USER_HOME/NordVPN/NordVPN-AUSTRIA.sh" <<'EOF'
#!/bin/sh
nordvpn connect Austria
EOF

# Adjust ownership and permissions
chown "$SUDO_USER:$SUDO_USER" "$USER_HOME/NordVPN/NordVPN-AUSTRIA.sh"
chmod +x "$USER_HOME/NordVPN/NordVPN-AUSTRIA.sh"

# ------------------------------

# Create the script file
cat >"$USER_HOME/NordVPN/NordVPN-SWISS.sh" <<'EOF'
#!/bin/sh
nordvpn connect Switzerland
EOF

# Adjust ownership and permissions
chown "$SUDO_USER:$SUDO_USER" "$USER_HOME/NordVPN/NordVPN-SWISS.sh"
chmod +x "$USER_HOME/NordVPN/NordVPN-SWISS.sh"

# ------------------------------

# Create the script file
cat >"$USER_HOME/NordVPN/NordVPN-DISCONNECT.sh" <<'EOF'
#!/bin/sh
nordvpn disconnect
EOF

# Adjust ownership and permissions
chown "$SUDO_USER:$SUDO_USER" "$USER_HOME/NordVPN/NordVPN-DISCONNECT.sh"
chmod +x "$USER_HOME/NordVPN/NordVPN-DISCONNECT.sh"

# ------------------------------

# Create the script file
cat >"$USER_HOME/NordVPN/NordVPN-STATUS.sh" <<'EOF'
#!/bin/sh
nordvpn disconnect
EOF

# Adjust ownership and permissions
chown "$SUDO_USER:$SUDO_USER" "$USER_HOME/NordVPN/NordVPN-STATUS.sh"
chmod +x "$USER_HOME/NordVPN/NordVPN-STATUS.sh"

# ------------------------------

# Create the script file
cat >"$USER_HOME/NordVPN/Run STATUS.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Terminal=true
Name=Run Script
Exec=/bin/sh /home/avo/Schreibtisch/NordVPN-STATUS.sh
Icon=utilities-terminal
Name[de_DE]=Run STATUS
EOF

# Adjust ownership and permissions
chown "$SUDO_USER:$SUDO_USER" "$USER_HOME/NordVPN/Run STATUS.desktop"
chmod +x "$USER_HOME/NordVPN/Run STATUS.desktop"

# --------------------------------------------------------------------------------------------------------
#   Make a Timeshift Snapshot
# --------------------------------------------------------------------------------------------------------
timeshift --create --comments "NordVPN installed" --tags D




## ########################################################################################################
##
##   Install pCloud
##
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
## ########################################################################################################

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
  autostart_file="$HOME/.config/autostart/pcloud.desktop"

  # Make sure autostart directory exists
  mkdir -p "$HOME/.config/autostart" || { echo "Error: Unable to create autostart directory."; exit 1; }

  # Create autostart entry
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








## ########################################################################################################
##
##   xxxxx
##
## ########################################################################################################








## ########################################################################################################
##
##   xxxxx
##
## ########################################################################################################










