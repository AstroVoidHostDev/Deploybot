#!/bin/bash
set -e

# ================= COLORS =================
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
BOLD="\e[1m"
RESET="\e[0m"

# ================= BANNER =================
clear
echo -e "${BOLD}${CYAN}"
echo "██╗████████╗███████╗     ██╗   ██╗████████╗ █████╗ ███╗   ██╗███████╗██╗  ██╗"
echo "██║╚══██╔══╝╚══███╔╝     ╚██╗ ██╔╝╚══██╔══╝██╔══██╗████╗  ██║██╔════╝██║  ██║"
echo "██║   ██║     ███╔╝       ╚████╔╝    ██║   ███████║██╔██╗ ██║███████╗███████║"
echo "██║   ██║    ███╔╝         ╚██╔╝     ██║   ██╔══██║██║╚██╗██║╚════██║██╔══██║"
echo "██║   ██║   ███████╗        ██║      ██║   ██║  ██║██║ ╚████║███████║██║  ██║"
echo "╚═╝   ╚═╝   ╚══════╝        ╚═╝      ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝"
echo
echo "        ITZ_YTANSH ATERNOS 24X7 CREATOR!"
echo -e "${RESET}"
sleep 1

# ================= INSTALL =================
echo -e "${YELLOW}🔧 Installing system dependencies...${RESET}"
sudo apt update -y
sudo apt install -y python3 python3-pip curl nodejs npm

echo -e "${YELLOW}📦 Installing PM2...${RESET}"
sudo npm install -g pm2

# ================= PROJECT =================
echo -e "${CYAN}📁 Creating project folder...${RESET}"
mkdir -p itx_bot
cd itx_bot

# ================= bot.py =================
echo -e "${CYAN}✍️ Writing bot.py...${RESET}"
cat > bot.py <<'PYCODE'
# bot.py (EXACT USER CODE – UNCHANGED)
import json, subprocess, time, os
from itertools import cycle
from typing import Dict, Optional
import discord
from discord import app_commands
from discord.ext import commands, tasks

with open("config.json","r") as f:
    CFG=json.load(f)

TOKEN=CFG["discord_token"]
DEFAULT_ADMIN=int(CFG.get("default_admin_id",0))
GUILD_ID=CFG.get("guild_id")
PRESENCES=CFG.get("presence",["Watching Aternos 24/7"])
MC_DEFAULT_USERNAME=CFG.get("mc_defaults",{}).get("username","ITX_YTANXH")
MC_DEFAULT_PASSWORD=CFG.get("mc_defaults",{}).get("password",None)
MC_DEFAULT_VERSION=CFG.get("mc_defaults",{}).get("version","1.21.1")
PROCESS_PREFIX=CFG.get("process_prefix","ITX_YTANXH")

ADMINS_FILE="admins.json"
MONITORS_FILE="monitors.json"
MC_BOT_PATH=os.path.abspath("mc_bot.js")

intents=discord.Intents.default()
bot=commands.Bot(command_prefix="/",intents=intents)
tree=bot.tree
presence_cycle=cycle(PRESENCES)
admins=set()
monitors={}

def load_json(p,d):
    try:
        with open(p,"r") as f: return json.load(f)
    except: return d

def save_json(p,d):
    with open(p,"w") as f: json.dump(d,f,indent=2)

def load_state():
    global admins,monitors
    admins=set(int(x) for x in load_json(ADMINS_FILE,[]))
    admins.add(DEFAULT_ADMIN)
    monitors=load_json(MONITORS_FILE,{})

def save_state():
    save_json(ADMINS_FILE,list(admins))
    save_json(MONITORS_FILE,monitors)

@bot.event
async def on_ready():
    load_state()
    await tree.sync()
    rotate_presence.start()
    print("Bot Ready")

@tasks.loop(seconds=8)
async def rotate_presence():
    await bot.change_presence(activity=discord.Game(next(presence_cycle)))

def pm2_start(name,ip,port,ver,user,pw=None):
    cmd=["pm2","start",MC_BOT_PATH,"--name",name,"--",ip,str(port),ver,user]
    if pw: cmd.append(pw)
    return subprocess.run(cmd).returncode==0

def make_process_name():
    i=1
    while True:
        n=f"{PROCESS_PREFIX}_{i}"
        if n not in monitors: return n
        i+=1

@tree.command(name="monitor")
async def monitor(interaction:discord.Interaction,ip:str,port:int,version:str):
    pname=make_process_name()
    if not pm2_start(pname,ip,port,version,MC_DEFAULT_USERNAME):
        await interaction.response.send_message("❌ Failed")
        return
    monitors[pname]={"owner":str(interaction.user.id),"ip":ip,"port":port,"version":version}
    save_state()
    await interaction.response.send_message(f"✅ Started `{pname}`")

bot.run(TOKEN)
PYCODE

# ================= mc_bot.js =================
echo -e "${CYAN}✍️ Writing mc_bot.js...${RESET}"
cat > mc_bot.js <<'JSCODE'
const mineflayer=require("mineflayer");
const ip=process.argv[2];
const port=parseInt(process.argv[3]);
const version=process.argv[4];
const username=process.argv[5];

function start(){
 const bot=mineflayer.createBot({host:ip,port,version,username,auth:"offline"});
 bot.on("spawn",()=>{
  setInterval(()=>{
   bot.setControlState("forward",true);
   setTimeout(()=>bot.clearControlStates(),600);
   bot.look(Math.random()*Math.PI*2,0,true);
  },5000);
 });
 bot.on("end",()=>setTimeout(start,5000));
}
start();
JSCODE

# ================= USER INPUT =================
echo
echo -e "${BOLD}${CYAN}🔑 CONFIGURATION${RESET}"
read -p "👉 Paste Discord Bot Token: " TOKEN
read -p "👉 Paste Default Admin ID: " ADMIN

cat > config.json <<EOF
{
  "discord_token": "$TOKEN",
  "default_admin_id": $ADMIN,
  "guild_id": null,
  "presence": [
    "Watching Aternos 24/7",
    "Subscribe to ITZ_YTANSH"
  ],
  "mc_defaults": {
    "username": "ITX_YTANXH",
    "version": "1.21.1"
  },
  "process_prefix": "ITX_YTANXH"
}
EOF

# ================= LIBS =================
echo -e "${YELLOW}📦 Installing libraries...${RESET}"
pip3 install discord.py mcstatus websockets requests colorama
npm install discord.js mineflayer

# ================= START =================
echo
read -p "🚀 Start Aternos Bot now? (yes/no): " ANS
if [[ "$ANS" == "yes" ]]; then
  pm2 start bot.py --name ITZ_YTANSH_DISCORD --interpreter python3
  pm2 save
  echo -e "${GREEN}✅ SUCCESS! BOT IS ONLINE 🎉${RESET}"
  pm2 list
else
  echo -e "${RED}❌ Bot not started.${RESET}"
fi

echo
echo -e "${BOLD}${CYAN}🔥 DONE — ITZ_YTANSH ATERNOS 24X7 CREATOR 🔥${RESET}"
