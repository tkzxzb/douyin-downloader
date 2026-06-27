FROM python:3.11-slim

# 创建与 HF Space 一致的用户 (uid=1000)
RUN useradd -m -u 1000 user

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    gcc \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 安装 Python 依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 安装 REST API 依赖
RUN pip install --no-cache-dir fastapi uvicorn

# 复制项目代码
COPY . .

# 创建启动脚本（运行时生成 config.yml，注入 Secrets）
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 切换到非 root 用户
USER user

# HF Space 默认端口 7860
EXPOSE 7860

ENTRYPOINT ["/entrypoint.sh"]
