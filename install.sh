#!/bin/bash

# Update and upgrade system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install necessary packages
sudo apt-get install -y python3-dev sqlmap python-is-python3 libatspi2.0-0 libasound2 libxdamage1 libgbm1 libxkbcommon0 libxfixes3 libatk1.0-0 libxrandr2 libxcomposite1 libatk-bridge-2.0-0 unzip

# Install gdown
pip3 install gdown

# Download file using gdown
gdown --id 1y5X0LSmMBF-WiQAUntVXie_LMQbHwp9G -O acunetix.zip

# Unzip the downloaded file
unzip acunetix.zip

# Change directory to the extracted Acunetix folder
cd Acunetix-v24-2

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
echo "2607:f8b0:402a:80a::200e  telemetry.invicti.com." | sudo tee -a /etc/hosts

# Save /etc/hosts
sudo cp /etc/hosts /etc/hosts.saved

# Run Acunetix installer
sudo bash acunetix_24.2.240226074_x64.sh

# Stop Acunetix service
sudo systemctl stop acunetix.service

# Replace wvsc
sudo cp wvsc /home/acunetix/.acunetix/v_240226074/scanner/wvsc
sudo chown acunetix:acunetix /home/acunetix/.acunetix/v_240226074/scanner/wvsc
sudo chmod +x /home/acunetix/.acunetix/v_240226074/scanner/wvsc

# Replace license files
sudo rm /home/acunetix/.acunetix/data/license/*
sudo cp license_info.json /home/acunetix/.acunetix/data/license/
sudo cp wa_data.dat /home/acunetix/.acunetix/data/license/
sudo chown acunetix:acunetix /home/acunetix/.acunetix/data/license/license_info.json
sudo chown acunetix:acunetix /home/acunetix/.acunetix/data/license/wa_data.dat
sudo chmod 444 /home/acunetix/.acunetix/data/license/license_info.json
sudo chmod 444 /home/acunetix/.acunetix/data/license/wa_data.dat
sudo chattr +i /home/acunetix/.acunetix/data/license/license_info.json
sudo chattr +i /home/acunetix/.acunetix/data/license/wa_data.dat

# Restart Acunetix service
sudo systemctl restart acunetix.service
