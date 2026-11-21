"""Simple, portable BMI calculator for adult users.

Run with: python3 BMI.py
Height is entered in centimetres; weight is entered in kilograms.
"""

import math


def calculate_bmi(weight_kg, height_cm):
    """Return BMI using kilograms and centimetres; reject invalid measurements."""
    try:
        weight = float(weight_kg)
        height = float(height_cm)
    except (TypeError, ValueError):
        raise ValueError("體重與身高必須是有效數字。")

    if not math.isfinite(weight) or not math.isfinite(height):
        raise ValueError("體重與身高必須是有限數字。")
    if weight <= 0 or height <= 0:
        raise ValueError("體重與身高必須大於 0。")

    height_m = height / 100.0
    return weight / (height_m * height_m)


def bmi_category(bmi):
    """Return an adult BMI category using Taiwan HPA reference ranges."""
    if bmi < 18.5:
        return "體重過輕"
    if bmi < 24:
        return "健康體重"
    if bmi < 27:
        return "體重過重"
    return "肥胖"


def main():
    print("BMI 計算器（體重：公斤，身高：公分）")
    try:
        weight = input("請輸入體重（公斤）：").strip()
        height = input("請輸入身高（公分）：").strip()
        bmi = calculate_bmi(weight, height)
    except ValueError as error:
        print("輸入錯誤：{}".format(error))
        return 1

    print("您的 BMI 為：{:.1f}".format(bmi))
    print("成人 BMI 分類：{}".format(bmi_category(bmi)))
    print("此結果僅供參考，不作為醫療診斷。")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
