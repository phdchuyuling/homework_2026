"""BMI 計算程式（身高以公分、體重以公斤輸入）。"""


def main():
    try:
        height_cm = float(input("請輸入身高（公分）："))
        weight_kg = float(input("請輸入體重（公斤）："))
    except ValueError:
        print("輸入錯誤：身高和體重請輸入數字。")
        return

    if height_cm <= 0 or weight_kg <= 0:
        print("輸入錯誤：身高和體重必須大於 0。")
        return

    height_m = height_cm / 100
    bmi = weight_kg / (height_m ** 2)

    if bmi < 18.5:
        category = "體重過輕"
    elif bmi < 24:
        category = "健康體重"
    elif bmi < 27:
        category = "體重過重"
    elif bmi < 30:
        category = "輕度肥胖"
    elif bmi < 35:
        category = "中度肥胖"
    else:
        category = "重度肥胖"

    print(f"您的 BMI 為：{bmi:.2f}")
    print(f"體位分類：{category}")


if __name__ == "__main__":
    main()
