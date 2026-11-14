# BMI 計算程式作業

本作業為德霖資工 1A、2A 同學的作業繳交說明。

## 作業要求

1. **作業名稱：** BMI 計算程式
2. **檔名：** `學號BMI`，請將「學號」替換成自己的學號，並依程式語言加上正確副檔名。例如：`你的學號BMI.py`。檔名中的 `+` 表示學號與 `BMI` 直接相連，不需輸入加號。
3. **可攜式架構：** 程式應能在不同電腦環境執行；避免使用僅適用於自己電腦的絕對路徑或環境設定，並一併提供程式執行所需的檔案與依賴說明。
4. **Fork：** 請先 Fork 本作業儲存庫至自己的 GitHub 帳號，再在自己的 Fork 中新增作業檔案。
5. **PR 繳交：** 完成並推送作業後，向本儲存庫的 `main` 分支建立 Pull Request（PR）作為繳交。建立 PR 時，請依 PR 內的「作業繳交檢核表」逐項確認並勾選。PR 標題請註明作業名稱與學號，內容請提供姓名、學號及程式執行方式。

## 繳交流程

1. 登入 GitHub，Fork 本儲存庫。
2. 在自己的 Fork 新增 BMI 程式，並依規定命名檔案。
3. Commit 並 Push 變更至自己的 Fork。
4. 從自己的作業分支建立 PR，目標為本儲存庫的 `main` 分支。
5. 完成 PR 內的「作業繳交檢核表」，確認檔案及繳交資訊正確後送出。
# BMI 計算程式
# 執行方式：python 學號BMI.py
# 使用 Python 3，無須安裝第三方套件。

def calculate_bmi(height_cm, weight_kg):
    """依身高（公分）與體重（公斤）計算 BMI。"""
    height_m = height_cm / 100
    return weight_kg / (height_m ** 2)


def get_category(bmi):
    """成人 BMI 分類（台灣常用標準）。"""
    if bmi < 18.5:
        return "體重過輕"
    elif bmi < 24:
        return "正常範圍"
    elif bmi < 27:
        return "過重"
    else:
        return "肥胖"


def main():
    print("=" * 32)
    print("          BMI 計算程式")
    print("=" * 32)

    try:
        height = float(input("請輸入身高（公分）："))
        weight = float(input("請輸入體重（公斤）："))

        if height <= 0 or weight <= 0:
            print("錯誤：身高和體重必須大於 0。")
            return

        if not (50 <= height <= 250):
            print("提醒：請確認身高是否以公分輸入。")
            return

        if not (10 <= weight <= 500):
            print("提醒：請確認體重數值是否正確。")
            return

        bmi = calculate_bmi(height, weight)

        print("\n---------- 計算結果 ----------")
        print(f"身高：{height:.1f} 公分")
        print(f"體重：{weight:.1f} 公斤")
        print(f"BMI：{bmi:.2f}")
        print(f"體位判定：{get_category(bmi)}")
        print("------------------------------")
        print("註：此分類供一般成人參考，不適用於兒童及孕婦。")

    except ValueError:
        print("輸入錯誤：請輸入有效的數字。")


if __name__ == "__main__":
    main()

