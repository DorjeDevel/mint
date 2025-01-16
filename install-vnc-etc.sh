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
## ########################################################################################################

# Determine the original user and their home directory
USER_HOME=$(eval echo ~${SUDO_USER:-$USER})
EXEC_USER=${SUDO_USER:-$USER}

# Check system architecture (64-bit only)
if [ "$(uname -m)" != "x86_64" ]; then
  echo "This script supports only 64-bit systems."
  exit 1
fi

# Download pCloud AppImage
echo "Downloading pCloud AppImage..."
wget -O "$USER_HOME/pcloud" https://download.pcloud.com/latest/x86_64/pcloud

# Make the AppImage executable
chmod +x "$USER_HOME/pcloud"

# Start pCloud
echo "Starting pCloud..."
sudo -u "$EXEC_USER" "$USER_HOME/pcloud" &

# Add pCloud to startup applications
echo "Adding pCloud to startup applications..."
mkdir -p "$USER_HOME/.config/autostart"
cat > "$USER_HOME/.config/autostart/pcloud.desktop" <<EOL
[Desktop Entry]
Type=Application
Exec=$USER_HOME/pcloud
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=pCloud
Comment=pCloud Drive
EOL

# Set correct ownership for the user
chown "$EXEC_USER:$EXEC_USER" "$USER_HOME/pcloud"
chown -R "$EXEC_USER:$EXEC_USER" "$USER_HOME/.config/autostart"

echo "Installation complete. pCloud has been added to startup and should now be running."


# --------------------------------------------------------------------------------------------------------
#   Make a Timeshift Snapshot
# --------------------------------------------------------------------------------------------------------
timeshift --create --comments "pCloud installed" --tags D








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










