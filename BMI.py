"""Run with Python 3.8 or newer. No third-party packages are required."""

import math
import re


def read_positive_number(prompt):
    value = input(prompt).strip()
    if not re.fullmatch(r"[+-]?(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)(?:[eE][+-]?[0-9]+)?", value):
        raise ValueError("Please enter a positive number without units.")
    number = float(value)
    if not math.isfinite(number) or number <= 0:
        raise ValueError("Please enter a finite positive number.")
    return number


def main():
    try:
        weight = read_positive_number("Weight (kg): ")
        height = read_positive_number("Height (cm): ") / 100
        height_squared = height * height
        if not math.isfinite(height_squared) or height_squared == 0:
            raise ValueError("Height is outside the supported range.")
        bmi = weight / height_squared
        if not math.isfinite(bmi) or bmi <= 0:
            raise ValueError("BMI is outside the supported range.")
    except (EOFError, ValueError) as error:
        print(f"Error: {error or 'Input ended before both values were entered.'}")
        return 1

    print(f"BMI: {bmi:.2f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
