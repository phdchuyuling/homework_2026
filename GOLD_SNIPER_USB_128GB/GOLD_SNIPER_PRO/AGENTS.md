# GOLD SNIPER PRO - Codex project guidance

- This project is a signal-notification system only. Never add broker order execution.
- Never invent live GC prices, market data, fills, TP/SL hits, or performance.
- If no authorized market-data feed is connected, report DATA SOURCE DISCONNECTED.
- Keep API secrets out of frontend code, browser storage, logs, Git, and TradingView alert bodies.
- The current backend is a TradingView webhook bridge and SQLite signal recorder, not a complete ICT/SMC engine.
- Keep test/simulation signals visibly separated from live signals.
- Use confirmed candles and avoid lookahead/repainting in any strategy implementation.
- Require explicit tests before claiming a strategy or integration works.
