#!/bin/bash

# ================== COLORS ==================
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
BOLD="\033[1m"
RESET="\033[0m"

# ================== BANNER ==================
clear
echo -e "${BOLD}${CYAN}"
echo "██╗████████╗███████╗    ██╗   ██╗████████╗ █████╗ ███╗   ██╗███████╗██╗  ██╗"
echo "██║╚══██╔══╝╚══███╔╝    ╚██╗ ██╔╝╚══██╔══╝██╔══██╗████╗  ██║██╔════╝██║  ██║"
echo "██║   ██║     ███╔╝      ╚████╔╝    ██║   ███████║██╔██╗ ██║███████╗███████║"
echo "██║   ██║    ███╔╝        ╚██╔╝     ██║   ██╔══██║██║╚██╗██║╚════██║██╔══██║"
echo "██║   ██║   ███████╗       ██║      ██║   ██║  ██║██║ ╚████║███████║██║  ██║"
echo "╚═╝   ╚═╝   ╚══════╝       ╚═╝      ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝"
echo -e "${RESET}"
echo -e "${BOLD}${YELLOW}      ITZ_YTANSH ATERNOS 24X7 CREATOR!${RESET}"
echo
sleep 2

# ================== SYSTEM UPDATE ==================
echo -e "${CYAN}Updating system...${RESET}"
sudo apt update -y && sudo apt upgrade -y

# ================== INSTALL PYTHON ==================
echo -e "${CYAN}Installing Python & pip...${RESET}"
sudo apt install python3 python3-pip -y

# ================== INSTALL NODE 18 ==================
echo -e "${CYAN}Installing Node.js 18...${RESET}"
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# ================== INSTALL PM2 ==================
echo -e "${CYAN}Installing PM2 (24/7 runtime)...${RESET}"
sudo npm install -g pm2

# ================== PROJECT FOLDER ==================
echo -e "${CYAN}Creating project folder...${RESET}"
mkdir -p itx_bot
cd itx_bot || exit

# ================== CREATE FILES ==================
echo -e "${CYAN}Creating files...${RESET}"
touch bot.py mc_bot.js config.json

# ================== NODE MODULES ==================
echo -e "${CYAN}Installing Node modules...${RESET}"
npm install discord.js mineflayer

# ================== PYTHON MODULES ==================
echo -e "${CYAN}Installing Python libraries...${RESET}"
pip install discord.py mcstatus websockets requests colorama

# ================== PM2 START PLACEHOLDER ==================
echo -e "${YELLOW}"
echo "--------------------------------------------------"
echo " NOW DO THIS MANUALLY (IMPORTANT)"
echo "--------------------------------------------------"
echo "1) Paste your bot code into:"
echo "   - bot.py"
echo "   - mc_bot.js"
echo
echo "2) Edit config.json and add:"
echo "   - Discord Token"
echo "   - Admin ID"
echo
echo "3) Then run:"
echo "   pm2 start mc_bot.js --name mc-bot"
echo "   pm2 start bot.py --name discordBot"
echo "   pm2 save"
echo "   pm2 startup"
echo "--------------------------------------------------"
echo -e "${RESET}"

echo -e "${GREEN}${BOLD}SETUP COMPLETED SUCCESSFULLY!${RESET}"
echo -e "${CYAN}Subscribe To ITZ_YTANSH ❤️${RESET}"
