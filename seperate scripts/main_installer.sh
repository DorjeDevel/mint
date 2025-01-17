#!/bin/bash

clear

echo
echo "------------------------------------------------------------------------------"
echo 
echo "Welcome to the App Installer!"
echo 
echo "You can now install x11VNC, Enpass, NordVPN, pCloud & Mediathekview."
echo 
echo "After installing NordVPN, reboot and restart this script to continue."
echo
echo "------------------------------------------------------------------------------"
echo

# Ask the user if they want to take a snapshot
read -p "Do you want to take a snapshot before proceeding? (y/n): " snapshot_choice
if [[ $snapshot_choice == "y" || $snapshot_choice == "Y" ]]; then
    echo "Creating a snapshot..."
    # Replace the following line with your snapshot creation command
    echo "Snapshot created successfully!"
else
    echo "On your own risk."
fi

echo
echo "------------------------------------------------------------------------------"
echo
apps=("VNC" "Enpass" "NordVPN" "pCloud" "Mediathekview")

for app in "${apps[@]}"; do
    read -p "Do you want to install $app? (y/n): " choice
    if [[ $choice == "y" || $choice == "Y" ]]; then
        case $app in
            "VNC") bash install_vnc.sh ;;
            "Enpass") bash install_enpass.sh ;;
            "NordVPN") bash install_nordvpn.sh ;;
            "pCloud") bash install_pcloud.sh ;;
            "Mediathekview") bash install_media.sh ;;
        esac
    fi
done

echo "------------------------------------------------------------------------------"
echo "Installation process complete!"
echo "Please check the output above!"
echo "Have Fun!"
echo


