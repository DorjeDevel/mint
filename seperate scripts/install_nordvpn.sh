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
