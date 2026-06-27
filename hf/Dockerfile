FROM python:3.11-slim

RUN useradd -m -u 1000 user

WORKDIR /app

RUN apt-get update && apt-get install -y \
    gcc curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir fastapi uvicorn pyyaml

COPY . .

# 把 hf/ 的文件放到固定路径，entrypoint 运行时再 cp 到 /app
RUN mkdir -p /hf
COPY hf/index.html /hf/index.html
COPY hf/hf_patch.py /hf/hf_patch.py
COPY hf/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN chown -R user:user /app /hf

USER user

EXPOSE 7860

ENTRYPOINT ["/entrypoint.sh"]
