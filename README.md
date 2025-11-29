<p align="center">
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=28&pause=900&color=00F7FF&center=true&vCenter=true&width=650&lines=ITX_YTANXH+Discord+%2B+Minecraft+Bot;Fast+%7C+Secure+%7C+Professional;Made+For+Cracked+and+Premium+Servers" />
</p>

<p align="center">
  <img src="https://share.creavite.co/692b35d9476f6b0f5a2e62cc.gif" width="440">
</p>

<h1 align="center">⚡ ITX_YTANXH – Dual Discord × Minecraft Bot System ⚡</h1>

<p align="center">
A powerful **Discord Slash Bot** + **Minecraft Chat Monitor** system that works on <b>cracked and premium servers</b>.  
Fully compatible with <b>Minecraft 1.21+</b> and <b>Python 3.10 + Node.js 18+</b>.
</p>

---

# ✨ Features
✔️ Professional Discord Status  
✔️ Slash Commands (Admin & Monitoring)  
✔️ Minecraft Player Monitor  
✔️ Real-Time Chat Sync (Optional)  
✔️ Cracked + Online UUID Support  
✔️ PM2 Auto-Restart (24/7 Hosting)  
✔️ Clean Code (Python + Node.js)  
✔️ Fully Custom Bot Name (ITX_YTANXH)

---

# 🛠️ 1. Install Dependencies

### 🐧 **System Update**
```bash
sudo apt update -y && sudo apt upgrade -y
```

### 🐍 **Install Python 3.10 + pip**
```bash
sudo apt install python3 python3-pip -y
```

### 🟦 **Install Node.js 18**
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

### ♾️ **Install PM2 (24/7 Runtime)**
```bash
sudo npm install -g pm2
```

---

# 📁 2. Create Project Folder
```bash
mkdir itx_bot
cd itx_bot
```

---

# 📄 3. Create Required Files

You must create **3 files**:

| File | Purpose |
|------|---------|
| `bot.py` | Python Minecraft Bot |
| `bot.js` | Discord Slash Bot |
| `config.json` | Settings |

---

## ✏️ 3.1 Create `bot.py`
```bash
nano bot.py
```
Paste your working Python bot code.  
Save → **CTRL + O → ENTER → CTRL + X**

---

## ✏️ 3.2 Create `bot.js`
```bash
nano bot.js
```
Paste your working JS bot code.  
Save → **CTRL + O → ENTER → CTRL + X**

---

## ⚙️ 3.3 Create `config.json`
```bash
nano config.json
```

Paste:

```json
{
  "token": "YOUR_DISCORD_BOT_TOKEN",
  "guild": "YOUR_GUILD_ID",
  "minecraft_ip": "SERVER_IP",
  "minecraft_port": 25565
}
```

Save and exit.

---

# 📦 4. Install Node Modules
```bash
npm install discord.js mineflayer
```

---

# 🐍 5. Install Python Libraries
```bash
pip install discord.py mcstatus websockets requests colorama
```

---

# 🚀 6. Start Bots Using PM2

### Start Python Minecraft Bot
```bash
pm2 start bot.py --name mc-bot
```

### Start Discord JS Bot
```bash
pm2 start bot.js --name discordBot
```

### Save PM2 Startup
```bash
pm2 save
pm2 startup
```

---

# 📊 7. Check Bot Status
```bash
pm2 list
```

🟢 **online** = running  
🔴 **errored** = fix needed  

---

# 🔧 Slash Commands Included

| Command | Description |
|---------|-------------|
| `/admin @user` | Add admin |
| `/unadmin @user` | Remove admin |
| `/list` | List admins |
| `/monitor player` | Start monitoring |
| `/unmonitor player` | Stop monitoring |
| `/status` | Bot health/status |

---

# 🖥️ Bot Name
Your bot joins Minecraft as:

```
ITX_YTANXH
```

---

# 🖤 Support & Upgrades

If you want:
- Full Minecraft chat → Discord sync  
- Web dashboard  
- Anti-cheat alerts  
- Join/Leave logging  
- Auto-restart on MC crash  
- More slash commands  

Just ask — I will upgrade it 🔥

---

# ⭐ Enjoy your professional dual-bot system!

