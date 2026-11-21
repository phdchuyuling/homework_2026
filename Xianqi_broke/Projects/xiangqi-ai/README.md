# 象棋 AI 對弈

## 執行
- 雙擊 `RUN_GAME.bat`，或直接雙擊 `index.html`，使用 Chrome / Edge 開啟。
- VS Code：File > Open Folder，選擇 `xiangqi-ai`；在 Explorer 點 `index.html`，再以瀏覽器開啟。
- 不需要 Node.js、Python、Flutter、網路或額外套件。

## 功能
- 9×10 棋盤及紅黑 32 子；車、馬、象、士、將、炮、兵／卒走法。
- 馬腿、象眼、炮架、過河、九宮、將帥照面與自陷將軍限制。
- 黑方 AI（alpha-beta 搜尋，快速／一般／較強）。
- 將軍、將死、困斃判定；悔棋、翻轉棋盤。
- 棋譜回看、從舊局面建立分支、自動保存、手動保存與載入。
- 離線執行，資料存在瀏覽器 localStorage。

AI 為輕量搜尋引擎，非職業級象棋引擎。