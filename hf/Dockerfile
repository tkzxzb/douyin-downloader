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

# 复制启动脚本，赋予执行权限（在 root 阶段操作）
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 让 user 可以写 /app（可选，防止其他运行时写文件报错）
RUN chown -R user:user /app

# 切换到非 root 用户
USER user

EXPOSE 7860

ENTRYPOINT ["/entrypoint.sh"]
