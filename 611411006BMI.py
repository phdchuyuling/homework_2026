#!/usr/bin/env python3

"""BMI 計算程式"""


def calculate_bmi(weight_kg: float, height_cm: float) -> float:
    """計算 BMI，參數分別為體重（kg）與身高（cm）。"""
    if weight_kg <= 0 or height_cm <= 0:
        raise ValueError("體重與身高必須為正數。")

    height_m = height_cm / 100
    return weight_kg / (height_m ** 2)


def classify_bmi(bmi: float) -> str:
    """依 BMI 結果回傳分類。"""
    if bmi < 18.5:
        return "體重過輕"
    elif bmi < 24:
        return "正常範圍"
    elif bmi < 27:
        return "過重"
    elif bmi < 30:
        return "輕度肥胖"
    elif bmi < 35:
        return "中度肥胖"
    else:
        return "重度肥胖"


def display_result(weight: float, height: float) -> None:
    """顯示 BMI 計算結果。"""
    bmi = calculate_bmi(weight, height)
    result = classify_bmi(bmi)

    print("\n=== BMI 計算結果 ===")
    print(f"體重：{weight} kg")
    print(f"身高：{height} cm")
    print(f"BMI：{bmi:.2f}")
    print(f"判定結果：{result}")
    print("====================\n")
