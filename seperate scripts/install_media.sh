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



