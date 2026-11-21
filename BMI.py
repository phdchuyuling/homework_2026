"""簡單、可攜的 BMI 命令列計算程式。體重單位為 kg，身高單位為 cm。"""

import math
import sys


def read_positive_finite(prompt: str) -> float:
    """讀取有限且大於零的數值；輸入不合法時提供明確錯誤。"""
    raw_value = input(prompt).strip()
    if not raw_value:
        raise ValueError("輸入不可空白。")

    try:
        value = float(raw_value)
    except ValueError as exc:
        raise ValueError("請輸入純數字（可包含小數），不要加上單位文字。") from exc

    if not math.isfinite(value):
        raise ValueError("數值必須是有限值，不能是 NaN 或 Infinity。")
    if value <= 0:
        raise ValueError("數值必須大於 0。")
    return value


def calculate_bmi(weight_kg: float, height_cm: float) -> float:
    """依 kg 與 cm 計算 BMI，並拒絕無法表示的結果。"""
    height_m = height_cm / 100.0
    bmi = weight_kg / (height_m * height_m)
    if not math.isfinite(bmi):
        raise ValueError("輸入數值超出可計算範圍，請檢查體重與身高。")
    return bmi


def main() -> int:
    print("BMI 計算程式（體重：kg；身高：cm）")
    try:
        weight_kg = read_positive_finite("請輸入體重（kg）：")
        height_cm = read_positive_finite("請輸入身高（cm）：")
        bmi = calculate_bmi(weight_kg, height_cm)
    except (ValueError, OverflowError, ZeroDivisionError) as error:
        print(f"輸入錯誤：{error}", file=sys.stderr)
        return 1

    print(f"BMI：{bmi:.2f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
