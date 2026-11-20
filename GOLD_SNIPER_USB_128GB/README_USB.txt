GOLD SNIPER USB 128GB - PORTABLE WORKSTATION
=============================================

這是 Windows 10/11 x64 的可攜式專案套件。
目前提供：USB 內 Python runtime、Portable VS Code、官方 OpenAI Codex
VS Code 擴充功能、TradingView Webhook 接收後端、SQLite 訊號紀錄、
Edge Dashboard、一鍵啟動/停止/檢查腳本。

快速開始
--------
1. 將整個資料夾解壓到 128GB USB（建議 USB 3.0）。
2. 在有網路的 Windows 10/11 x64 電腦上，雙擊 install.bat。
   首次安裝會下載 Python embeddable、pip 套件、VS Code ZIP 與
   官方 OpenAI Codex 擴充功能；這一步需要網路。
3. 雙擊 START.bat。
4. VS Code 會開啟 GOLD_SNIPER_PRO 專案；在 Codex 側邊欄使用 ChatGPT
   帳號登入。第一次登入需要網路及帳號具備 Codex 使用權。
5. Edge 會開啟 http://127.0.0.1:8000。
6. 結束時雙擊 STOP.bat。

可攜性與限制
------------
- Python runtime、VS Code 程式、擴充功能及專案檔放在 USB。
- 官方 Codex 擴充功能需登入 OpenAI/ChatGPT 帳號；不保證完全離線。
- 此套件不是自動執行 autorun。Windows 通常不允許 USB 插入即自動執行，
  請插入後雙擊 START.bat。
- 本套件不包含真實 GC 即時行情 feed、Telegram 憑證或完整 ICT/SMC
  策略引擎。現有 TradingView bridge 僅接收 Alert JSON 並存入 SQLite。
- TradingView 雲端無法直接呼叫 127.0.0.1。需另行設定外部 HTTPS Tunnel
  並將 URL 貼入 TradingView Alert。
- 不可將 TEST 訊號當作真實績效；沒有行情 feed 時不得推算 TP/SL 觸及。
- USB 運作時不可拔除；建議定期備份 GOLD_SNIPER_PRO/data。
- 此版本尚未在你的實際電腦與 USB 裝置上驗證。完成首次安裝後請執行
  CHECK.bat 並做 Webhook 測試。

官方文件
--------
Codex IDE： https://learn.chatgpt.com/docs/codex/ide
Codex CLI Windows： https://github.com/openai/codex
Python： https://www.python.org/downloads/
VS Code： https://code.visualstudio.com/
