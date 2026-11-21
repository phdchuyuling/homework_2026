"""BMI 計算程式。

輸入：體重（公斤）與身高（公分）。
公式：BMI = 體重（kg） / (身高（cm） / 100) ** 2
"""

import math


def parse_positive_finite_number(raw: str, field_name: str) -> float:
    """將輸入轉成有限正數；輸入不合法時拋出 ValueError。"""
    value_text = raw.strip()
    if not value_text:
        raise ValueError(f"{field_name}不可空白，請輸入正數。")

    try:
        value = float(value_text)
    except ValueError as exc:
        raise ValueError(f"{field_name}必須是純數值，例如 60 或 170.5。") from exc

    if not math.isfinite(value):
        raise ValueError(f"{field_name}必須是有限數值，不可使用 NaN 或 Infinity。")
    if value <= 0:
        raise ValueError(f"{field_name}必須大於 0。")
    return value


def calculate_bmi(weight_kg: float, height_cm: float) -> float:
    """依公斤及公分計算 BMI，並拒絕無法合理計算的結果。"""
    if not math.isfinite(weight_kg) or not math.isfinite(height_cm):
        raise ValueError("體重與身高必須是有限數值。")
    if weight_kg <= 0 or height_cm <= 0:
        raise ValueError("體重與身高必須大於 0。")

    height_m = height_cm / 100.0
    denominator = height_m * height_m
    if denominator == 0.0 or not math.isfinite(denominator):
        raise ValueError("身高數值無法合理計算。")

    bmi = weight_kg / denominator
    if not math.isfinite(bmi):
        raise ValueError("BMI 結果超出可處理範圍。")
    return bmi


def read_measurement(prompt: str, field_name: str) -> float:
    """持續要求輸入，直到取得有限正數；EOF 時乾淨結束。"""
    while True:
        try:
            raw = input(prompt)
        except (EOFError, KeyboardInterrupt):
            print("\n已取消輸入。")
            raise SystemExit(0)

        try:
            return parse_positive_finite_number(raw, field_name)
        except ValueError as error:
            print(f"輸入錯誤：{error}")


def main() -> None:
    print("=== BMI 計算程式 ===")
    print("請輸入純數值：體重單位為 kg，身高單位為 cm。")

    weight_kg = read_measurement("體重（kg）：", "體重")
    height_cm = read_measurement("身高（cm）：", "身高")

    try:
        bmi = calculate_bmi(weight_kg, height_cm)
    except ValueError as error:
        # 理論上輸入已在 read_measurement 驗證；保留此防護避免任何無效結果輸出。
        print(f"輸入錯誤：{error}")
        return

    print(f"BMI：{bmi:.2f}")


if __name__ == "__main__":
    main()
