# bot.py
import json
import subprocess
import time
import os
from itertools import cycle
from typing import Dict, Optional

import discord
from discord import app_commands
from discord.ext import commands, tasks

# ---------------- load config ----------------
with open("config.json", "r") as f:
    CFG = json.load(f)

TOKEN = CFG["discord_token"]
DEFAULT_ADMIN = int(CFG.get("default_admin_id", 0))
GUILD_ID = CFG.get("guild_id")  # None => global
PRESENCES = CFG.get("presence", ["Watching Aternos 24/7"])
MC_DEFAULT_USERNAME = CFG.get("mc_defaults", {}).get("username", "ITX_YTANXH")
MC_DEFAULT_VERSION = CFG.get("mc_defaults", {}).get("version", "1.21.1")
PROCESS_PREFIX = CFG.get("process_prefix", "ITX_YTANXH")

ADMINS_FILE = "admins.json"
MONITORS_FILE = "monitors.json"

intents = discord.Intents.default()
bot = commands.Bot(command_prefix="/", intents=intents)
tree: app_commands.CommandTree = bot.tree

presence_cycle = cycle(PRESENCES)
admins = set()
monitors: Dict[str, Dict] = {}  # key: process_name -> {owner, ip, port, version, ts_started}

# ---------------- persistence ----------------
def load_json(path, default):
    try:
        with open(path, "r") as f:
            return json.load(f)
    except Exception:
        return default

def save_json(path, data):
    with open(path, "w") as f:
        json.dump(data, f, indent=2)

def load_state():
    global admins, monitors
    a = load_json(ADMINS_FILE, [])
    admins = set(int(x) for x in a) if a else set()
    admins.add(DEFAULT_ADMIN)
    monitors = load_json(MONITORS_FILE, {})

def save_state():
    save_json(ADMINS_FILE, list(admins))
    save_json(MONITORS_FILE, monitors)

# ---------------- PM2 helpers ----------------
def pm2_available() -> bool:
    try:
        subprocess.run(["pm2", "ping"], capture_output=True, timeout=3)
        return True
    except Exception:
        return False

def pm2_start(process_name: str, ip: str, port: int, version: str, username: str) -> bool:
    try:
        cmd = ["pm2", "start", "mc_bot.js", "--name", process_name, "--", ip, str(port), version, username]
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode != 0:
            print("pm2 start failed:", res.stdout, res.stderr)
            return False
        return True
    except FileNotFoundError:
        return False
    except Exception as e:
        print("pm2_start exception:", e)
        return False

def pm2_delete(process_name: str) -> bool:
    try:
        res = subprocess.run(["pm2", "delete", process_name], capture_output=True, text=True)
        return res.returncode == 0
    except Exception:
        return False

def spawn_node_background(ip: str, port: int, version: str, username: str, process_name: str) -> bool:
    # fallback: spawn detached node process with PROCESS_NAME in argv so we can identify it
    try:
        cmd = ["node", "mc_bot.js", ip, str(port), version, username, process_name]
        subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
        return True
    except Exception as e:
        print("spawn_node_background error:", e)
        return False

def pm2_jlist() -> list:
    try:
        out = subprocess.check_output(["pm2", "jlist"], text=True)
        return json.loads(out)
    except Exception:
        return []

def pm2_is_running(name: str) -> bool:
    for p in pm2_jlist():
        try:
            if p.get("name") == name and p.get("pm2_env", {}).get("status") == "online":
                return True
        except Exception:
            continue
    return False

# ---------------- process naming ----------------
def make_process_name() -> str:
    # produce next available name like PREFIX_1, PREFIX_2 ...
    existing = set(monitors.keys())
    n = 1
    while True:
        name = f"{PROCESS_PREFIX}_{n}"
        if name not in existing and not pm2_is_running(name):
            return name
        n += 1

# ---------------- monitors status ----------------
def get_monitors_with_state() -> Dict[str, Dict]:
    result = {}
    for pname, info in monitors.items():
        running = pm2_is_running(pname) if pm2_available() else False
        result[pname] = {**info, "running": running}
    return result

# ---------------- events / tasks ----------------
@bot.event
async def on_ready():
    load_state()
    print("Bot ready:", bot.user)
    try:
        if GUILD_ID:
            await tree.sync(guild=discord.Object(id=int(GUILD_ID)))
            print("Synced to guild", GUILD_ID)
        else:
            await tree.sync()
            print("Global commands sync called (may take up to 1 hour to propagate).")
    except Exception as e:
        print("Command sync error:", e)
    rotate_presence.start()

@tasks.loop(seconds=8.0)
async def rotate_presence():
    try:
        await bot.change_presence(activity=discord.Game(next(presence_cycle)))
    except Exception:
        pass

def is_admin(user: discord.User) -> bool:
    return int(user.id) in admins

# ---------------- slash commands ----------------
@tree.command(name="admin", description="Grant admin to a user (admins only)")
@app_commands.describe(member="User to grant admin")
async def cmd_admin(interaction: discord.Interaction, member: discord.Member):
    if not is_admin(interaction.user):
        await interaction.response.send_message("❌ You are not authorized.", ephemeral=True)
        return
    admins.add(int(member.id))
    save_state()
    await interaction.response.send_message(f"✅ {member.mention} is now an admin.")

@tree.command(name="unadmin", description="Remove admin from a user (admins only)")
@app_commands.describe(member="User to remove admin")
async def cmd_unadmin(interaction: discord.Interaction, member: discord.Member):
    if not is_admin(interaction.user):
        await interaction.response.send_message("❌ You are not authorized.", ephemeral=True)
        return
    if int(member.id) == int(DEFAULT_ADMIN):
        await interaction.response.send_message("❗ Cannot remove default admin.", ephemeral=True)
        return
    admins.discard(int(member.id))
    save_state()
    await interaction.response.send_message(f"✅ Removed admin: {member.mention}")

@tree.command(name="list", description="List admins and active monitors")
async def cmd_list(interaction: discord.Interaction):
    admin_lines = [f"<@{a}>" for a in sorted(admins)]
    admin_text = "\n".join(admin_lines) if admin_lines else "No admins"
    mon = get_monitors_with_state()
    if mon:
        mon_lines = []
        for pname, info in mon.items():
            owner = info.get("owner", "Unknown")
            running = "🟢" if info.get("running") else "🔴"
            mon_lines.append(f"{running} <@{owner}> → `{info.get('ip','?')}:{info.get('port','?')}` ({info.get('version','?')}) | `{pname}`")
        monitors_text = "\n".join(mon_lines)
    else:
        monitors_text = "No active monitors"
    embed = discord.Embed(title="📋 Admins & Monitors", color=0x00ccff)
    embed.add_field(name="👑 Admins", value=admin_text, inline=False)
    embed.add_field(name="🛰 Monitors", value=monitors_text, inline=False)
    await interaction.response.send_message(embed=embed)

@tree.command(name="monitor", description="Start a Minecraft monitor (admin only)")
@app_commands.describe(ip="Server IP/domain", port="Server port", version="MC version (eg. 1.21.1)")
async def cmd_monitor(interaction: discord.Interaction, ip: str, port: int, version: str):
    if not is_admin(interaction.user):
        await interaction.response.send_message("❌ Only admins can start monitors.", ephemeral=True)
        return

    pname = make_process_name()
    username = MC_DEFAULT_USERNAME
    started = False

    if pm2_available():
        started = pm2_start(pname, ip, port, version, username)
    if not started:
        # fallback: spawn node with process name appended as last arg
        started = spawn_node_background(ip, port, version, username, pname)

    if not started:
        await interaction.response.send_message("❌ Failed to start mc bot (pm2/node error). Check host logs.", ephemeral=True)
        return

    monitors[pname] = {
        "owner": str(interaction.user.id),
        "ip": ip,
        "port": int(port),
        "version": version,
        "process": pname,
        "ts_started": int(time.time())
    }
    save_state()
    await interaction.response.send_message(f"✅ Started monitor `{pname}` for `{ip}:{port}` as `{username}`.")

@tree.command(name="unmonitor", description="Stop a monitor (admins or owner)")
@app_commands.describe(process="Process name to stop (leave empty to stop your most recent)")
async def cmd_unmonitor(interaction: discord.Interaction, process: Optional[str] = None):
    caller = str(interaction.user.id)

    if process:
        info = monitors.get(process)
        if not info:
            await interaction.response.send_message("❌ No such monitor/process.", ephemeral=True)
            return
        owner = info.get("owner")
    else:
        # find most recent monitor owned by caller
        owned = [(k, v) for k, v in monitors.items() if v.get("owner") == caller]
        if not owned:
            await interaction.response.send_message("❌ You have no active monitors.", ephemeral=True)
            return
        owned.sort(key=lambda it: it[1].get("ts_started", 0), reverse=True)
        process, info = owned[0]
        owner = info.get("owner")

    if not (is_admin(interaction.user) or owner == caller):
        await interaction.response.send_message("❌ Not authorized to stop that monitor.", ephemeral=True)
        return

    pname = info.get("process")
    stopped = False
    if pm2_available():
        stopped = pm2_delete(pname)
    else:
        try:
            subprocess.run(["pkill", "-f", f"mc_bot.js.*{pname}"], check=False)
            stopped = True
        except Exception:
            stopped = False

    monitors.pop(pname, None)
    save_state()
    await interaction.response.send_message(f"🛑 Monitor `{pname}` stopped.")

@tree.command(name="status", description="Show professional bot + monitor status")
async def cmd_status(interaction: discord.Interaction):
    embed = discord.Embed(title="📊 Bot Status", color=0x2ecc71)
    embed.add_field(name="🤖 Discord Bot", value="🟢 Online", inline=False)

    mon = get_monitors_with_state()
    if mon:
        lines = []
        for pname, info in mon.items():
            owner = info.get("owner", "Unknown")
            running = "🟢 Online" if info.get("running") else "🔴 Offline"
            lines.append(f"{running} • <@{owner}> — `{info.get('ip','?')}:{info.get('port','?')}` ({info.get('version','?')}) | `{pname}`")
        embed.add_field(name="🟩 Minecraft Monitors", value="\n".join(lines), inline=False)
    else:
        embed.add_field(name="🟩 Minecraft Monitors", value="No monitors running", inline=False)

    embed.set_footer(text=f"Bots join as {MC_DEFAULT_USERNAME} • Managed by admins")
    await interaction.response.send_message(embed=embed)

# ---------------- shutdown ----------------
def graceful_shutdown():
    save_state()

# ---------------- run ----------------
if __name__ == "__main__":
    load_state()
    try:
        bot.run(TOKEN)
    finally:
        graceful_shutdown()
