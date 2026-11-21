"""BMI 計算程式（Python 3.8+，不需安裝額外套件）。

執行方式：python BMI.py
體重輸入公斤（kg），身高輸入公分（cm）。
"""

import math


def parse_positive_number(raw_value, field_name):
    """將文字轉為有限正數；無效時拋出 ValueError。"""
    if not raw_value.strip():
        raise ValueError(f"{field_name}不可空白，請輸入數字。")
    try:
        number = float(raw_value)
    except ValueError:
        raise ValueError(f"{field_name}只能輸入純數字（不可包含單位文字）。") from None
    if not math.isfinite(number):
        raise ValueError(f"{field_name}必須是有限的數字。")
    if number <= 0:
        raise ValueError(f"{field_name}必須大於 0。")
    return number


def calculate_bmi(weight_kg, height_cm):
    """計算 BMI，並拒絕無法產生有限正數結果的輸入。"""
    if not all(math.isfinite(x) and x > 0 for x in (weight_kg, height_cm)):
        raise ValueError("體重和身高必須是有限正數。")
    height_m = height_cm / 100.0
    try:
        bmi = weight_kg / (height_m * height_m)
    except (ZeroDivisionError, OverflowError):
        raise ValueError("數值超出可計算範圍，請重新輸入。") from None
    if not math.isfinite(bmi) or bmi <= 0:
        raise ValueError("數值超出可計算範圍，請重新輸入。")
    return bmi


def main():
    print("=== BMI 計算程式 ===")
    print("體重單位：公斤 (kg)；身高單位：公分 (cm)")
    print("輸入 q 可離開程式。\n")
    while True:
        try:
            weight_text = input("請輸入體重 (kg)：")
            if weight_text.strip().lower() == "q":
                break
            weight = parse_positive_number(weight_text, "體重")

            height_text = input("請輸入身高 (cm)：")
            if height_text.strip().lower() == "q":
                break
            height = parse_positive_number(height_text, "身高")

            bmi = calculate_bmi(weight, height)
            print(f"您的 BMI：{bmi:.2f}\n")
        except ValueError as error:
            print(f"輸入錯誤：{error}\n請重新輸入體重與身高。\n")
        except (EOFError, KeyboardInterrupt):
            print()
            break
    print("程式已結束。")


if __name__ == "__main__":
    main()
