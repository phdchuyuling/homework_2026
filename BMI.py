"""BMI 計算程式（Python 3.8+，僅使用標準函式庫）。

執行方式：python BMI.py
體重輸入公斤（kg）、身高輸入公分（cm）。
輸入 q 可結束程式。
"""

import math


def parse_positive_number(raw, field):
    """將輸入轉為有限正數；無效時拋出 ValueError。"""
    raw = raw.strip()
    if not raw:
        raise ValueError(f"{field}不可空白。")
    try:
        value = float(raw)
    except ValueError:
        raise ValueError(f"{field}請輸入純數字，不要包含單位或文字。") from None
    if not math.isfinite(value):
        raise ValueError(f"{field}必須是有限的數字。")
    if value <= 0:
        raise ValueError(f"{field}必須大於 0。")
    return value


def calculate_bmi(weight_kg, height_cm):
    """計算 BMI；任何無法合理計算的數值都會被拒絕。"""
    if not (math.isfinite(weight_kg) and math.isfinite(height_cm)):
        raise ValueError("體重與身高必須是有限數字。")
    if weight_kg <= 0 or height_cm <= 0:
        raise ValueError("體重與身高必須大於 0。")
    height_m = height_cm / 100.0
    if height_m == 0 or not math.isfinite(height_m):
        raise ValueError("身高超出可計算範圍。")
    denominator = height_m * height_m
    if denominator == 0 or not math.isfinite(denominator):
        raise ValueError("身高超出可計算範圍。")
    bmi = weight_kg / denominator
    if not math.isfinite(bmi) or bmi < 0.005:
        raise ValueError("數值超出可計算範圍，無法得到有效 BMI。")
    return bmi


def main():
    print("=" * 38)
    print("            BMI 計算程式")
    print("=" * 38)
    print("輸入體重 (kg) 與身高 (cm)；輸入 q 結束。")
    while True:
        try:
            weight_raw = input("\n請輸入體重 (kg)：")
            if weight_raw.strip().lower() == "q":
                break
            weight = parse_positive_number(weight_raw, "體重")

            height_raw = input("請輸入身高 (cm)：")
            if height_raw.strip().lower() == "q":
                break
            height = parse_positive_number(height_raw, "身高")

            bmi = calculate_bmi(weight, height)
            print(f"計算結果：BMI = {bmi:.2f}")
        except ValueError as exc:
            print(f"輸入錯誤：{exc} 請重新輸入。")
        except (EOFError, KeyboardInterrupt):
            print("\n輸入已結束。")
            break
    print("感謝使用 BMI 計算程式！")


if __name__ == "__main__":
    main()
