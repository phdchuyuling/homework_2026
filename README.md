# BMI 計算程式

## 作業資料

- 姓名：請填寫姓名
- 學號：請填寫學號
- 班級：德霖資工 1A／2A
- 作業名稱：BMI 計算程式
- 程式語言：Dart
- 開發框架：Flutter

## 程式說明

本程式讓使用者輸入身高（公分）與體重（公斤），並使用下列公式計算 BMI：

```text
BMI = 體重（kg）÷ 身高（m）²
```

程式會顯示 BMI 數值及體位判定結果：

- BMI < 18.5：體重過輕
- 18.5 ≤ BMI < 24：體重正常
- 24 ≤ BMI < 27：體重過重
- BMI ≥ 27：肥胖

## 作業檔案

請將程式檔案命名為：

```text
你的學號BMI.dart
```

例如學號為 `12345678`：

```text
12345678BMI.dart
```

## 執行環境與依賴

- Flutter Stable
- Dart SDK（包含於 Flutter SDK）
- Material Design 元件（由 Flutter SDK 提供）
- 沒有使用第三方套件
- 沒有使用絕對路徑或限定個人電腦的設定

## 執行方式

請先確認 Flutter 環境：

```bash
flutter doctor
```

取得專案依賴：

```bash
flutter pub get
```

如果作業檔案位於 Repository 根目錄，請執行：

```bash
flutter run -t 你的學號BMI.dart
```

例如：

```bash
flutter run -t 12345678BMI.dart
```

如果作業檔案放在 `lib` 資料夾，請執行：

```bash
flutter run -t lib/你的學號BMI.dart
```

## 操作方式

1. 在身高欄位輸入身高，單位為公分。
2. 在體重欄位輸入體重，單位為公斤。
3. 按下「立即計算」。
4. 畫面會顯示 BMI 數值及體位判定結果。

## 可攜性說明

本程式未使用絕對路徑及外部資料檔案。只要電腦已安裝相容版本的 Flutter SDK，即可取得依賴並執行程式。
