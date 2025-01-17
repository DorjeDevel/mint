echo
echo "------------------------------------------------------------------------------"
echo
echo "Installing pCloud..."
echo 
##    Original script from:
##    https://surajdeshpande.wordpress.com/2021/01/18/upgrade-pcloud-version-on-ubuntu-using-shell-script/
##    Updated and extended by DorjeDevel
##    Version: 2025-01-16 
##    Note: Manual download is required for this script.
echo 

# Determine the original user and their home directory
USER_HOME=$(eval echo ~${SUDO_USER:-$USER})
EXEC_USER=${SUDO_USER:-$USER}

# Check system architecture (64-bit only)
if [ "$(uname -m)" != "x86_64" ]; then
  echo "This script supports only 64-bit systems."
  exit 1
fi

# Prompt user to download the file manually and open the URL in the default browser
echo "The download URL will be opened in your default browser."
echo "Please download the pCloud executable and save it as 'pcloud' in your Downloads folder."
echo
echo "If the browser does not open, please visit this URL manually:"
echo "https://www.pcloud.com/how-to-install-pcloud-drive-linux.html?download=electron-64"
echo

# Open the URL in the browser as the original user
sudo -u "$EXEC_USER" xdg-open "https://www.pcloud.com/how-to-install-pcloud-drive-linux.html?download=electron-64" || { echo "Error: Unable to open the browser."; exit 1; }

# Wait for user confirmation
echo "Press ENTER once you have downloaded the file to continue..."
read

# Change directory to downloads folder
echo 'Jumping to Downloads...'
cd "$USER_HOME/Downloads" || { echo "Error: Unable to access Downloads folder."; exit 1; }
pwd
echo

# Check if the file exists
if [ ! -f "pcloud" ]; then
  echo "Error: 'pcloud' file not found in Downloads folder. Please make sure to download it correctly."
  exit 1
fi

# Get the size of the downloaded file
file_size=$(stat -c%s "pcloud")

# Minimum size in bytes (50 MB = 50 * 1024 * 1024)
min_size=$((50 * 1024 * 1024))

# Check the size
if [ "$file_size" -ge "$min_size" ]; then
  echo "File size is valid. Proceeding with installation..."

  # Allow executing file as a program
  echo 'Making file executable...'
  chmod +x pcloud || { echo "Error: Failed to make the file executable."; exit 1; }

  # Kill existing pcloud processes
  echo 'Killing existing pcloud processes...'
  pgrep -u $EXEC_USER -f pcloud | xargs -r sudo kill -9

  # Remove existing pcloud file in /usr/bin if it exists
  if [ -f "/usr/bin/pcloud" ]; then
    echo 'Removing existing pcloud file in /usr/bin...'
    sudo rm -f /usr/bin/pcloud || { echo "Error: Failed to remove existing pcloud file."; exit 1; }
  fi

  # Copy updated version to bin folder
  echo 'Copying updated version to bin folder...'
  sudo cp pcloud /usr/bin/ || { echo "Error: Failed to copy pcloud to /usr/bin."; exit 1; }
  echo 
  echo 'Starting pCloud...'
  nohup pcloud > "$HOME/.pcloud.log" 2>&1 &

  echo "------------------------------------------------------------------------------"
  echo "Adding pcloud to autostart..."

  # Make sure autostart directory exists
  mkdir -p "$USER_HOME/.config/autostart" || { echo "Error: Unable to create autostart directory."; exit 1; }

  # Create autostart entry
  autostart_file="$USER_HOME/.config/autostart/pcloud.desktop"
  echo "[Desktop Entry]" > "$autostart_file"
  echo "Type=Application" >> "$autostart_file"
  echo "Exec=/usr/bin/pcloud" >> "$autostart_file"
  echo "Hidden=false" >> "$autostart_file"
  echo "NoDisplay=false" >> "$autostart_file"
  echo "X-GNOME-Autostart-enabled=true" >> "$autostart_file"
  echo "Name=pCloud" >> "$autostart_file"
  echo "Comment=Start pCloud at login" >> "$autostart_file"

  echo "pCloud has been added to autostart."
  echo

  # Set correct ownership for the user
  echo "------------------------------------------------------------------------------"
  echo "Setting correct ownership to pcloud for current user..."
  chown "$EXEC_USER:$EXEC_USER" "$USER_HOME/Downloads/pcloud"
  chown -R "$EXEC_USER:$EXEC_USER" "$USER_HOME/.config/autostart"

  echo
  echo "Installation complete."
  echo "pCloud has been added to startup and should now be running."
  echo
else
  echo "File is too small. Please check your download and try again."
  exit 1
fi


