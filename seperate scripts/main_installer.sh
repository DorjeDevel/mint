
#!/bin/bash

echo "Welcome to the App Installer!"
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

echo "Installation process complete!"
