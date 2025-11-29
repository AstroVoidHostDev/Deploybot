// mc_bot.js
const mineflayer = require("mineflayer");

if (process.argv.length < 6) {
  console.log("Usage: node mc_bot.js <ip> <port> <version> <username> [process_name]");
  process.exit(1);
}

const ip = process.argv[2];
const port = parseInt(process.argv[3], 10);
const version = process.argv[4];
const username = process.argv[5];
const processName = process.argv[6] || username;

function startBot() {
  const bot = mineflayer.createBot({
    host: ip,
    port: port,
    version: version,
    username: username,
    auth: "offline"
  });

  bot.on("login", () => {
    console.log(`[${processName}] Logged in as ${username} -> ${ip}:${port}`);
  });

  bot.on("spawn", () => {
    console.log(`[${processName}] Spawned in world — starting anti-AFK.`);

    bot._afkTimer = setInterval(() => {
      if (!bot.entity) return;
      // short random forward
      bot.setControlState("forward", true);
      setTimeout(() => bot.clearControlStates(), 700 + Math.floor(Math.random() * 600));
      // random yaw
      bot.look(Math.random() * Math.PI * 2, 0, true);
    }, 5000 + Math.floor(Math.random() * 3000));
  });

  bot.on("kicked", (reason) => {
    console.log(`[${processName}] KICKED:`, reason);
  });

  bot.on("error", (err) => {
    console.log(`[${processName}] ERROR:`, err && err.message ? err.message : err);
  });

  bot.on("end", () => {
    console.log(`[${processName}] Disconnected. Reconnecting in 5s...`);
    if (bot._afkTimer) clearInterval(bot._afkTimer);
    setTimeout(startBot, 5000);
  });

  process.on("SIGINT", () => {
    try { if (bot._afkTimer) clearInterval(bot._afkTimer); } catch(e) {}
    try { bot.quit(); } catch(e) {}
    process.exit();
  });
}

startBot();
