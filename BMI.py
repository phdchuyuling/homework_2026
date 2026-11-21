def calculate_bmi(height, weight):
    """Calculate BMI using height in centimeters and weight in kilograms."""
    height_m = height / 100
    return weight / (height_m ** 2)


def main():
    print("========================")
    print("       BMI 計算程式")
    print("========================")

    try:
        height = float(input("請輸入身高（公分）："))
        weight = float(input("請輸入體重（公斤）："))

        if height <= 0 or weight <= 0:
            print("錯誤：身高與體重必須大於 0！")
            return

        bmi = calculate_bmi(height, weight)

        print("------------------------")
        print(f"您的身高：{height} 公分")
        print(f"您的體重：{weight} 公斤")
        print(f"您的 BMI：{bmi:.2f}")
        print("------------------------")

    except ValueError:
        print("錯誤：請輸入有效的數字！")


if __name__ == "__main__":
    main()
