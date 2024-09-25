#!/bin/bash

# Update and upgrade system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install necessary packages
sudo apt-get install -y python3-dev sqlmap python-is-python3 libatspi2.0-0 libasound2 libxdamage1 libgbm1 libxkbcommon0 libxfixes3 libatk1.0-0 libxrandr2 libxcomposite1 libatk-bridge2.0-0 unzip libcups2 libpango1.0-0 libcairo2

# Install gdown
pip3 install gdown

# Download file using gdown
gdown --id 1y5X0LSmMBF-WiQAUntVXie_LMQbHwp9G -O acunetix.zip

# Unzip the downloaded file
unzip acunetix.zip

# Change directory to the extracted Acunetix folder
# Note: Ensure the folder name matches the actual extracted folder
cd Acunetix-v24-2 || { echo "Directory not found!"; exit 1; }

# Backup /etc/hosts before making changes
sudo cp /etc/hosts /etc/hosts.backup

# Add entries to /etc/hosts
echo "127.0.0.1  erp.acunetix.com" | sudo tee -a /etc/hosts
echo "127.0.0.1  erp.acunetix.com." | sudo tee -a /etc/hosts
echo "::1  erp.acunetix.com" | sudo tee -a /etc/hosts
echo "::1  erp.acunetix.com." | sudo tee -a /etc/hosts
echo "192.178.49.174  telemetry.invicti.com" | sudo tee -a /etc/hosts
echo "192.178.49.174  telemetry.invicti.com." | sudo tee -a /etc/hosts
echo "2607:f8b0:402a:80a::200e  telemetry.invicti.com" | sudo tee -a /etc/hosts
echo "2607:f8b0:402a:80a::200e  telemetry.invicti.com."

# Save /etc/hosts
sudo cp /etc/hosts /etc/hosts.saved

# Check if the acunetix user exists and delete it if necessary
if id "acunetix" &>/dev/null; then
  echo "User acunetix already exists. Removing to prevent conflict."
  sudo deluser --remove-home acunetix
  sudo groupdel acunetix
fi

# Create acunetix user and group with the home directory
sudo useradd -m -d /home/acunetix -r -s /bin/false acunetix
sudo groupadd acunetix
sudo usermod -aG acunetix acunetix

# Run Acunetix installer, ensure the file exists
if [ -f "acunetix_24.2.240226074_x64.sh" ]; then
  sudo bash acunetix_24.2.240226074_x64.sh
else
  echo "Acunetix installer not found. Exiting."
  exit 1
fi

# Stop Acunetix service if it exists
if systemctl is-active --quiet acunetix.service; then
  sudo systemctl stop acunetix.service
else
  echo "Acunetix service not found or not running."
fi

# Check if wvsc file exists before copying
if [ -f "wvsc" ]; then
  sudo mkdir -p /home/acunetix/.acunetix/v_240226074/scanner/
  sudo cp wvsc /home/acunetix/.acunetix/v_240226074/scanner/wvsc
  sudo chown acunetix:acunetix /home/acunetix/.acunetix/v_240226074/scanner/wvsc
  sudo chmod +x /home/acunetix/.acunetix/v_240226074/scanner/wvsc
else
  echo "wvsc file not found. Exiting."
  exit 1
fi

# Replace license files
sudo mkdir -p /home/acunetix/.acunetix/data/license/
if [ -f "license_info.json" ] && [ -f "wa_data.dat" ]; then
  sudo rm -f /home/acunetix/.acunetix/data/license/*
  sudo cp license_info.json /home/acunetix/.acunetix/data/license/
  sudo cp wa_data.dat /home/acunetix/.acunetix/data/license/
  sudo chown acunetix:acunetix /home/acunetix/.acunetix/data/license/license_info.json
  sudo chown acunetix:acunetix /home/acunetix/.acunetix/data/license/wa_data.dat
  sudo chmod 444 /home/acunetix/.acunetix/data/license/license_info.json
  sudo chmod 444 /home/acunetix/.acunetix/data/license/wa_data.dat
  sudo chattr +i /home/acunetix/.acunetix/data/license/license_info.json
  sudo chattr +i /home/acunetix/.acunetix/data/license/wa_data.dat
else
  echo "License files not found. Exiting."
  exit 1
fi

# Restart Acunetix service if installed
if systemctl list-units --full -all | grep -Fq "acunetix.service"; then
  sudo systemctl restart acunetix.service
else
  echo "Acunetix service not found. Unable to restart."
fi
