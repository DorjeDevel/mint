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
