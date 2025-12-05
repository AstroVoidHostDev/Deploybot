#!/bin/bash

echo "====================================="
echo "     🚀 DeployBot Installer"
echo "====================================="

# Update server
echo "[1] Updating system..."
apt update -y
apt upgrade -y

# Install dependencies
echo "[2] Installing dependencies..."
apt install -y curl wget git python3 python3-pip

# Clone repo
echo "[3] Downloading DeployBot..."
if [ -d "Deploybot" ]; then
    echo "Folder already exists. Updating..."
    cd Deploybot && git pull
else
    git clone https://github.com/AstroVoidHostDev/Deploybot
    cd Deploybot
fi

# Install Python requirements if requirements.txt exists
if [ -f "requirements.txt" ]; then
    echo "[4] Installing Python requirements..."
    pip3 install -r requirements.txt
fi

# Make bot executable
chmod +x bot.py

echo "====================================="
echo "✨ Installation Complete!"
echo "Run your bot using:"
echo "    python3 bot.py"
echo "====================================="
