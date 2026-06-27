---
title: Douyin Downloader
emoji: 🎬
colorFrom: red
colorTo: pink
sdk: docker
app_port: 7860
pinned: false
---

# Douyin Downloader

抖音批量下载工具，REST API 模式运行。

## API 使用

### 提交下载任务
```bash
curl -X POST http://your-space-url/api/v1/download \
  -H "Content-Type: application/json" \
  -d '{"url": "https://www.douyin.com/video/xxxxxxxxx"}'
```

### 查询任务状态
```bash
curl http://your-space-url/api/v1/jobs/{job_id}
```

### 查看所有任务
```bash
curl http://your-space-url/api/v1/jobs
```

### 健康检查
```bash
curl http://your-space-url/api/v1/health
```

## 环境变量（在 HF Space Secrets 中配置）

| 变量名 | 说明 |
|--------|------|
| `COOKIE_TTWID` | 抖音 cookie: ttwid |
| `COOKIE_MS_TOKEN` | 抖音 cookie: msToken |
| `COOKIE_ODIN_TT` | 抖音 cookie: odin_tt |
| `COOKIE_CSRF_TOKEN` | 抖音 cookie: passport_csrf_token |
| `COOKIE_SID_GUARD` | 抖音 cookie: sid_guard |
| `PROXY` | 代理地址（可选）|
