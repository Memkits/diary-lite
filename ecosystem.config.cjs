/**
 * PM2 configuration for a binary placed next to this file.
 *
 * Usage:
 *   DIARY_SECRET='replace-with-a-long-secret' \
 *   DIARY_USERS='demo:change-me' \
 *   pm2 start ecosystem.config.cjs
 */
module.exports = {
  apps: [
    {
      name: "diary-lite",
      script: "./diary-lite",
      cwd: __dirname,
      interpreter: "none",
      exec_mode: "fork",
      autorestart: true,
      watch: false,
      time: true,
      env: {
        DIARY_ADDR: "127.0.0.1:11031",
        DIARY_DB: "./data/diary.redb",
        DIARY_SECRET: process.env.DIARY_SECRET || "",
        DIARY_USERS: process.env.DIARY_USERS || "",
      },
    },
  ],
};
