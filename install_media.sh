echo
echo "------------------------------------------------------------------------------"
echo 
echo "Installing VLC and FFmpeg..."
echo

# Update the package list
echo "Updating package list..."
echo
sudo apt update || { echo "Failed to update package list!"; exit 1; }

# Upgrade the system
echo "Upgrading system packages..."
echo
sudo apt upgrade -y || { echo "Failed to upgrade packages!"; exit 1; }

# Install VLC
echo "------------------------------------------------------------------------------"
echo "Installing VLC..."
sudo apt install -y vlc || { echo "Failed to install VLC! See output above."; exit 1; }

# Debugging VLC installation
echo "Debugging VLC installation..."
sudo dpkg -L vlc | grep '/vlc$' || echo "VLC binary not found."

# Verify VLC installation
echo "------------------------------------------------------------------------------"
echo "Verifying VLC installation..."
vlc_path=$(which vlc 2>/dev/null)
if [ -x "$vlc_path" ]; then
    echo "VLC found at: $vlc_path"
    echo "Raw VLC version output:"
    vlc_version=$(sudo -u "$(logname)" "$vlc_path" --version 2>&1 | head -n 1)
    if [ -n "$vlc_version" ]; then
        echo "Parsed VLC version: $vlc_version"
    else
        vlc_version="Version could not be retrieved"
        echo "Failed to retrieve VLC version information."
    fi
else
    vlc_version="Not Installed"
    echo "VLC executable not found in PATH."
fi

# Install FFmpeg
echo "------------------------------------------------------------------------------"
echo "Installing FFmpeg..."
sudo apt install -y ffmpeg || { echo "Failed to install FFmpeg!"; exit 1; }

# Verify FFmpeg installation
echo "------------------------------------------------------------------------------"
echo "Verifying FFmpeg installation..."
ffmpeg_path=$(which ffmpeg 2>/dev/null)
if [ -x "$ffmpeg_path" ]; then
    ffmpeg_version=$("$ffmpeg_path" -version 2>/dev/null | head -n 1)
    echo "FFmpeg found: $ffmpeg_version"
else
    ffmpeg_version="Not Installed"
    echo "FFmpeg is not properly installed. Please check your package sources."
fi




# Install MediathekView
echo "------------------------------------------------------------------------------"
echo "Installing MediathekView..."
if sudo apt install -y mediathekview; then
    echo "MediathekView was successfully installed!"
else
    echo "Failed to install MediathekView. Please check for errors above."
    exit 1
fi

# Verify the installation
echo "------------------------------------------------------------------------------"
echo "Verifying MediathekView installation..."
if command -v mediathekview &> /dev/null; then
    echo "MediathekView is installed and ready to use!"
else
    echo "MediathekView seems not to be installed correctly. Please troubleshoot the issue."
    exit 1
fi


# Display installation results
echo "------------------------------------------------------------------------------"
echo "Installation Results:"
echo
echo "VLC:    ${vlc_version:-Not Installed}"
echo "FFmpeg: ${ffmpeg_version:-Not Installed}"
echo


