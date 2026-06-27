#!/bin/bash
set -e

# 写到 /tmp 避免权限问题（/app 是 root 权限）
CONFIG_FILE="/tmp/config.yml"

cat > "$CONFIG_FILE" <<EOF
link: []

path: /data/Downloaded/
mode:
  - post

number:
  post: 0
  collect: 0
  collectmix: 0

thread: 5
retry_times: 3
proxy: "${PROXY:-}"
database: true
database_path: /data/dy_downloader.db

progress:
  quiet_logs: true

cookies:
  msToken: "${COOKIE_MS_TOKEN:-}"
  ttwid: "${COOKIE_TTWID:-}"
  odin_tt: "${COOKIE_ODIN_TT:-}"
  passport_csrf_token: "${COOKIE_CSRF_TOKEN:-}"
  sid_guard: "${COOKIE_SID_GUARD:-}"

browser_fallback:
  enabled: false

notifications:
  enabled: false

server:
  max_jobs: 500
  job_ttl_seconds: 86400
EOF

echo "✅ config.yml generated at $CONFIG_FILE"
echo "🚀 Starting Douyin Downloader REST API on port 7860..."

exec python run.py --serve --serve-host 0.0.0.0 --serve-port 7860 -c "$CONFIG_FILE"
