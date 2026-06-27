#!/bin/bash
set -e

CONFIG_FILE="/tmp/config.yml"
PERSISTENT_CONFIG="/data/config.yml"

# 优先加载 /data 里用户保存的持久化 config（含 cookie）
if [ -f "$PERSISTENT_CONFIG" ]; then
  echo "✅ 加载持久化 config: $PERSISTENT_CONFIG"
  cp "$PERSISTENT_CONFIG" "$CONFIG_FILE"
else
  echo "📝 首次启动，生成默认 config..."
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
fi

# 把 hf/ 目录的文件复制到项目中
cp /hf/index.html /app/index.html
cp /hf/hf_patch.py /app/hf_patch.py

# 在 server/app.py 的 run_server 函数里注入 patch_app 调用
# 找到 "app = build_app(config)" 这行，在它后面插入两行
python3 - <<'PYEOF'
import re
path = "/app/server/app.py"
with open(path) as f:
    src = f.read()

inject = """
    # HF Space 补丁：注入 Web UI 和 /api/v1/config 接口
    try:
        from hf_patch import patch_app
        patch_app(app)
    except ImportError:
        pass
"""

# 只在还没注入过的情况下插入
if "hf_patch" not in src:
    src = src.replace(
        "    app = build_app(config)\n",
        "    app = build_app(config)\n" + inject
    )
    with open(path, "w") as f:
        f.write(src)
    print("✅ server/app.py patch 注入成功")
else:
    print("✅ server/app.py 已有 patch，跳过")
PYEOF

export CONFIG_PATH="$CONFIG_FILE"
echo "🚀 启动 Douyin Downloader，端口 7860..."
exec python run.py --serve --serve-host 0.0.0.0 --serve-port 7860 -c "$CONFIG_FILE"
