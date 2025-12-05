#!/bin/bash
set -e

REPO_URL="https://github.com/AstroVoidHostDev/Deploybot.git"
DEST_DIR="$HOME/Deploybot"

echo "=== Deploybot One-Click Installer ==="
echo "This script will clone the repo, install dependencies (Node 18, Python3, pip, pm2),"
echo "install required Python & Node packages, create a sample config.json and start the bots with pm2."
echo
read -p "Proceed? (y/N): " yn
if [[ ! "$yn" =~ ^[Yy] ]]; then
  echo "Aborting."
  exit 1
fi

# update & basic tools
echo "Updating system and installing basic packages..."
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y git curl wget build-essential

# install Node.js 18
if ! command -v node >/dev/null 2>&1 || [[ "$(node -v)" != v18* ]]; then
  echo "Installing Node.js 18..."
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt install -y nodejs
else
  echo "Node.js 18 already installed: $(node -v)"
fi

# install python3 and pip
if ! command -v python3 >/dev/null 2>&1; then
  echo "Installing Python3 and pip..."
  sudo apt install -y python3 python3-venv python3-pip
else
  echo "Python3 found: $(python3 --version)"
fi

# install pm2 globally
if ! command -v pm2 >/dev/null 2>&1; then
  echo "Installing pm2..."
  sudo npm install -g pm2
else
  echo "pm2 already installed: $(pm2 -v)"
fi

# clone or update repo
if [ -d "$DEST_DIR" ]; then
  echo "Repo folder $DEST_DIR already exists. Pulling latest changes..."
  cd "$DEST_DIR"
  git pull
else
  echo "Cloning repository into $DEST_DIR..."
  git clone "$REPO_URL" "$DEST_DIR"
  cd "$DEST_DIR"
fi

# Install Node dependencies (if package.json exists)
if [ -f package.json ]; then
  echo "Installing Node dependencies..."
  npm install
else
  echo "No package.json found, skipping npm install."
fi

# Create and activate Python venv for python dependencies
echo "Setting up Python virtual environment..."
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip

# Install Python requirements if any (try to detect)
if [ -f requirements.txt ]; then
  echo "Installing Python requirements from requirements.txt..."
  pip install -r requirements.txt
else
  # default installs from README suggestions
  echo "Installing common Python packages used by this repo..."
  pip install discord.py mcstatus websockets requests colorama
fi

# Create config.json if not present
CONFIG_FILE="config.json"
if [ -f "$CONFIG_FILE" ]; then
  echo "config.json already exists. Skipping creation."
else
  echo "Creating sample config.json at $DEST_DIR/$CONFIG_FILE"
  cat > "$CONFIG_FILE" <<'JSON'
{
  "discord_token": "YOUR_DISCORD_TOKEN_HERE",
  "default_admin_id": 123456789012345678,
  "guild_id": null,
  "presence": [
    "Watching Aternos 24/7",
    "Subscribe to ITZ_YTANSH",
    "Free Making Aternos 24/7",
    "AstroVoid Bot Aternos"
  ],
  "mc_defaults": {
    "username": "ITX_YTANXH",
    "version": "1.21.1"
  },
  "process_prefix": "ITX_YTANXH"
}
JSON
  echo "Sample config.json created. PLEASE EDIT it and put your Discord token and admin ID before starting bots."
fi

# Start bots with pm2
# Detect bot scripts
if [ -f bot.js ]; then
  echo "Starting bot.js with pm2 (name: discordBot-js)..."
  pm2 start bot.js --name discordBot-js --interpreter node
fi

if [ -f bot.py ]; then
  echo "Starting bot.py with pm2 (name: mc-bot-py)..."
  pm2 start bot.py --name mc-bot-py --interpreter python3
fi

# Save pm2 startup
echo "Saving pm2 process list and enabling startup..."
pm2 save
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u $USER --hp $HOME

echo
echo "=== Installation finished ==="
echo "Important: Edit config.json and replace placeholders (discord_token, default_admin_id)."
echo "To view logs: pm2 logs"
echo "To stop: pm2 stop all"
echo "To restart: pm2 restart all"
