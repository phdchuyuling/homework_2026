from __future__ import annotations
import json, os, sqlite3, hashlib
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from dotenv import load_dotenv

BASE = Path(__file__).resolve().parents[1]
load_dotenv(BASE / ".env")
DB_PATH = BASE / "data" / "signals.db"
WEBHOOK_PATH_TOKEN = os.getenv("WEBHOOK_PATH_TOKEN", "")
MIN_SCORE = int(os.getenv("MIN_SIGNAL_SCORE", "85"))
MIN_RR = float(os.getenv("MIN_RR", "2.0"))

app = FastAPI(title="GOLD SNIPER PRO TradingView Bridge", version="1.0.0")
app.mount("/assets", StaticFiles(directory=BASE / "frontend"), name="assets")

def db():
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    con = sqlite3.connect(DB_PATH)
    con.row_factory = sqlite3.Row
    con.execute("""CREATE TABLE IF NOT EXISTS signals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        signal_id TEXT UNIQUE NOT NULL,
        symbol TEXT, direction TEXT, timeframe TEXT,
        entry REAL, sl REAL, tp1 REAL, tp2 REAL, tp3 REAL,
        score REAL, rr REAL, timestamp TEXT, received_at TEXT,
        payload TEXT NOT NULL
    )""")
    con.commit()
    return con

@app.get("/")
def home():
    return FileResponse(BASE / "frontend" / "index.html")

@app.get("/api/status")
def status():
    return {"status":"online","mode":"TRADINGVIEW BRIDGE","webhook_configured":bool(WEBHOOK_PATH_TOKEN),
            "market_data":"TradingView alert events only; no independent quote feed",
            "server_time":datetime.now(timezone.utc).isoformat()}

@app.get("/api/signals")
def signals(limit: int = 50):
    limit = max(1, min(limit, 200))
    con=db()
    rows=con.execute("SELECT * FROM signals ORDER BY id DESC LIMIT ?",(limit,)).fetchall()
    con.close()
    return {"signals":[dict(r) for r in rows]}

@app.get("/api/signals/latest")
def latest():
    con=db()
    row=con.execute("SELECT * FROM signals ORDER BY id DESC LIMIT 1").fetchone()
    con.close()
    return {"signal":dict(row) if row else None}

@app.post("/webhook/tradingview/{token}")
async def tradingview_webhook(token: str, request: Request):
    # Use a long random URL path token. Do not put account passwords or broker credentials in alert messages.
    if not WEBHOOK_PATH_TOKEN or not hashlib.sha256(token.encode()).digest() == hashlib.sha256(WEBHOOK_PATH_TOKEN.encode()).digest():
        raise HTTPException(status_code=404, detail="Not found")
    try:
        payload = await request.json()
    except Exception:
        raise HTTPException(status_code=400, detail="Body must be valid JSON")
    required = ["signal_id","symbol","direction","entry","sl"]
    missing = [k for k in required if k not in payload]
    if missing:
        raise HTTPException(status_code=422, detail={"missing_fields":missing})
    direction = str(payload["direction"]).upper()
    if direction not in ("LONG","SHORT","BUY","SELL"):
        raise HTTPException(status_code=422, detail="direction must be LONG/SHORT/BUY/SELL")
    try:
        entry=float(payload["entry"]); sl=float(payload["sl"])
        score=float(payload.get("score",0))
        tp2=float(payload["tp2"]) if payload.get("tp2") is not None else None
    except (TypeError, ValueError):
        raise HTTPException(status_code=422, detail="Price and score fields must be numeric")
    if entry <= 0 or sl <= 0 or entry == sl:
        raise HTTPException(status_code=422, detail="Invalid entry/stop values")
    risk=abs(entry-sl)
    rr=abs(tp2-entry)/risk if tp2 is not None else None
    # Reject low-quality alerts at the receiver as a second safety gate.
    if score < MIN_SCORE:
        return {"accepted":False,"reason":"score_below_threshold","score":score}
    if rr is not None and rr < MIN_RR:
        return {"accepted":False,"reason":"rr_below_threshold","rr":rr}
    now=datetime.now(timezone.utc).isoformat()
    sid=str(payload["signal_id"])
    con=db()
    try:
        con.execute("""INSERT INTO signals
          (signal_id,symbol,direction,timeframe,entry,sl,tp1,tp2,tp3,score,rr,timestamp,received_at,payload)
          VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)""",
          (sid,str(payload["symbol"]),direction,str(payload.get("timeframe","5")),entry,sl,
           payload.get("tp1"),tp2,payload.get("tp3"),score,rr,str(payload.get("timestamp","")),now,json.dumps(payload)))
        con.commit()
    except sqlite3.IntegrityError:
        con.close()
        return {"accepted":True,"duplicate":True,"signal_id":sid}
    con.close()
    return {"accepted":True,"duplicate":False,"signal_id":sid,"received_at":now,"rr":rr}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app:app", host="127.0.0.1", port=8000, reload=False)
