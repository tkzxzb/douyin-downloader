"""
hf_patch.py
给原项目 FastAPI app 追加：
  GET  /                 — Web UI (index.html)
  GET  /api/v1/config    — 读取当前 cookie
  POST /api/v1/config    — 保存 cookie 到持久化 config
"""
from __future__ import annotations

import os
from pathlib import Path

import yaml
from fastapi import FastAPI
from fastapi.responses import HTMLResponse, JSONResponse
from pydantic import BaseModel

UI_PATH = Path(__file__).parent / "index.html"
CONFIG_PATH = Path(os.environ.get("CONFIG_PATH", "/tmp/config.yml"))
PERSISTENT_CONFIG = Path("/data/config.yml")


def _read_config() -> dict:
    if CONFIG_PATH.exists():
        with open(CONFIG_PATH) as f:
            return yaml.safe_load(f) or {}
    return {}


def _write_config(cfg: dict):
    # 写到运行时 config
    CONFIG_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(CONFIG_PATH, "w") as f:
        yaml.dump(cfg, f, allow_unicode=True)
    # 同步持久化到 /data
    if PERSISTENT_CONFIG.parent.exists():
        with open(PERSISTENT_CONFIG, "w") as f:
            yaml.dump(cfg, f, allow_unicode=True)


class CookiePayload(BaseModel):
    cookies: dict


def patch_app(app: FastAPI):
    @app.get("/", response_class=HTMLResponse, include_in_schema=False)
    async def serve_ui():
        if UI_PATH.exists():
            return HTMLResponse(UI_PATH.read_text(encoding="utf-8"))
        return HTMLResponse("<h2>UI not found — index.html missing</h2>", status_code=404)

    @app.get("/api/v1/config")
    async def get_config():
        cfg = _read_config()
        return JSONResponse({"cookies": cfg.get("cookies", {})})

    @app.post("/api/v1/config")
    async def save_config(payload: CookiePayload):
        cfg = _read_config()
        cfg["cookies"] = {**cfg.get("cookies", {}), **payload.cookies}
        _write_config(cfg)

        # 同时热更新运行中的 CookieManager（无需重启生效）
        try:
            from server.app import _ServerDeps  # noqa
            deps = getattr(app.state, "deps", None)
            if deps and hasattr(deps, "cookie_manager"):
                deps.cookie_manager.set_cookies(cfg["cookies"])
        except Exception:
            pass

        return JSONResponse({"ok": True, "message": "Cookie 已保存，立即生效"})
