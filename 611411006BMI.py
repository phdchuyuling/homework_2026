def calculate_bmi(weight_kg: float, height_cm: float) -> float:
    if height_cm <= 0 or weight_kg <= 0:
        raise ValueError("體重和身高必須為正數。")
    height_m = height_cm / 100
    return weight_kg / (height_m ** 2)


def get_bmi_category(bmi: float) -> str:
    if bmi < 18.5:
        return "體重過輕"
    elif bmi < 24:
        return "正常範圍"
    elif bmi < 27:
        return "過重"
    else:
        return "肥胖"


def main() -> None:
    print("=== BMI 計算程式 ===")
    print("請輸入您的身高與體重：")

    try:
        height_cm = float(input("身高（公分，例如 170）： ").strip())
        weight_kg = float(input("體重（公斤，例如 65）： ").strip())

        bmi = calculate_bmi(weight_kg, height_cm)
        category = get_bmi_category(bmi)

        print("\n計算結果：")
        print(f"BMI：{bmi:.2f}")
        print(f"判定：{category}")

    except ValueError as e:
        print(f"輸入錯誤：{e}")
        print("請確認您輸入的是有效的數字，且身高與體重皆為正數。")
    except KeyboardInterrupt:
        print("\n程式已被使用者中止。")


if __name__ == "__main__":
    main()
