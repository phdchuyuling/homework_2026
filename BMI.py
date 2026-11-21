import math
import sys
from decimal import Decimal, InvalidOperation, ROUND_HALF_UP


def parse_positive_finite_number(raw_value: str, field_name: str) -> float:
    """
    解析並驗證輸入字串是否為「有限的正數」。
    拒絕空白、僅空格、非純數值（如含單位 '60kg'）、0、負數、NaN、Infinity 及溢出數值。
    """
    if raw_value is None:
        raise ValueError(f"{field_name}不可為空值，請重新輸入正數。")

    cleaned = raw_value.strip()
    if not cleaned:
        raise ValueError(f"{field_name}不可為空白或僅包含空格，請重新輸入正數。")

    # 拒絕明確的非有限字串
    if cleaned.lower() in {"nan", "+nan", "-nan", "inf", "+inf", "-inf", "infinity", "+infinity", "-infinity"}:
        raise ValueError(f"{field_name}不可為非有限數值（NaN / Infinity），請重新輸入有限正數。")

    # 使用 Decimal 進行嚴格格式解析，避免 float("60kg") 報錯不明確，並避免二進位浮點誤差
    try:
        dec_val = Decimal(cleaned)
    except InvalidOperation:
        raise ValueError(f"{field_name}格式錯誤（請輸入純數字，勿包含單位或文字），您輸入的是：{raw_value!r}")

    if not dec_val.is_finite():
        raise ValueError(f"{field_name}必須為有限數值，請重新輸入。")

    if dec_val <= 0:
        raise ValueError(f"{field_name}必須大於 0（不可為零或負數），請重新輸入。")

    # 轉為 float 並檢查是否超出 IEEE 754 雙精度浮點數有限範圍（避免 Overflow）
    try:
        float_val = float(dec_val)
    except OverflowError:
        raise ValueError(f"{field_name}數值過大超出可處理範圍，請重新輸入合理正數。")

    if not math.isfinite(float_val) or float_val <= 0.0:
        raise ValueError(f"{field_name}數值超出可處理範圍，請重新輸入合理正數。")

    return float_val


def calculate_bmi(weight_kg: float, height_cm: float) -> float:
    """
    根據規格計算 BMI：
    BMI = 體重(kg) / (身高(cm) / 100)^2
    內部計算不提前截斷，並檢查計算結果是否為有限正數（避免極端數值平方後溢位或下溢為 0）。
    """
    if not (math.isfinite(weight_kg) and weight_kg > 0):
        raise ValueError("體重必須為有限正數。")
    if not (math.isfinite(height_cm) and height_cm > 0):
        raise ValueError("身高必須為有限正數。")

    height_m = height_cm / 100.0
    if height_m <= 0.0 or not math.isfinite(height_m):
        raise ValueError("身高換算為公尺後無效，請確認輸入範圍。")

    height_m_squared = height_m * height_m
    if height_m_squared <= 0.0 or not math.isfinite(height_m_squared):
        raise ValueError("身高數值超出可計算範圍（平方後發生溢位或下溢）。")

    bmi = weight_kg / height_m_squared
    if not math.isfinite(bmi) or bmi <= 0.0:
        raise ValueError("計算結果超出有效數值範圍，請確認輸入的體重與身高是否合理。")

    return bmi


def format_bmi(bmi: float) -> str:
    """
    依一般四捨五入（ROUND_HALF_UP）格式化至小數點後兩位，
    確保如 47.36 / 1.6^2 = 18.50、76.8 / 1.6^2 = 30.00 等邊界案例精準無誤。
    """
    rounded = Decimal(str(bmi)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    return f"{rounded:.2f}"


def prompt_valid_input(prompt_text: str, field_name: str) -> float:
    """
    持續提示使用者輸入，直到取得合法的有限正數為止；支援 Ctrl+C / EOF 安全離開。
    """
    while True:
        try:
            raw = input(prompt_text)
        except (EOFError, KeyboardInterrupt):
            print("\n程式已結束。")
            sys.exit(0)

        if raw.strip().lower() in {"q", "quit", "exit"}:
            print("已離開 BMI 計算程式。")
            sys.exit(0)

        try:
            return parse_positive_finite_number(raw, field_name)
        except ValueError as err:
            print(f"[輸入錯誤] {err}\n")


def main() -> None:
    print("=" * 45)
    print("BMI 計算程式（輸入單位：體重 kg / 身高 cm）")
    print("提示：輸入純數字即可，輸入 q 可隨時離開程式。")
    print("=" * 45)

    while True:
        weight_kg = prompt_valid_input("請輸入體重（公斤 kg）：", "體重")
        height_cm = prompt_valid_input("請輸入身高（公分 cm）：", "身高")

        try:
            bmi_value = calculate_bmi(weight_kg, height_cm)
            bmi_display = format_bmi(bmi_value)
            print(f"\n計算結果：BMI = {bmi_display}（原始計算值：{bmi_value:.6f}）\n")
        except ValueError as err:
            print(f"\n[計算錯誤] {err}\n")

        try:
            again = input("是否繼續計算下一筆？(按 Enter 繼續，輸入 n 或 q 離開)：").strip().lower()
        except (EOFError, KeyboardInterrupt):
            print("\n程式已結束。")
            break

        if again in {"n", "no", "q", "quit", "exit"}:
            print("感謝使用，程式已結束。")
            break
        print("-" * 45)


if __name__ == "__main__":
    main()
