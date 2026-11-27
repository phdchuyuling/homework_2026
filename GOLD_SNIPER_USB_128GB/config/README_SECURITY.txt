GOLD SNIPER USB - 憑證安全說明

目前版本不提供在 Dashboard 輸入或儲存真實 Token 的功能。
不要把 Telegram Bot Token、行情 API Key、券商帳密貼到網頁設定頁、
TradingView Alert 訊息、程式碼或日誌。

install.bat 會產生一組隨機 Webhook URL 路徑識別碼，寫入專案根目錄
的 .env。它不是 Telegram Token 或券商憑證。請妥善保管 USB，
不要公開 Webhook URL；遺失 USB 時請重新產生識別碼並更新 TradingView Alert。

Telegram 與即時行情供應商憑證尚未整合至本版本。正式整合時應採用
加密憑證庫／作業系統安全儲存，而不是網頁 localStorage。
