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
