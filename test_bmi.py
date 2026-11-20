import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from BMI import bmi_category, calculate_bmi


class BmiCalculatorTests(unittest.TestCase):
    def test_calculates_bmi(self):
        self.assertAlmostEqual(calculate_bmi(68, 170), 68 / (1.7 ** 2))

    def test_accepts_numeric_strings(self):
        self.assertAlmostEqual(calculate_bmi("68", "170"), 68 / (1.7 ** 2))

    def test_rejects_non_numeric_input(self):
        with self.assertRaises(ValueError):
            calculate_bmi("abc", 170)

    def test_rejects_zero_or_negative_values(self):
        for weight, height in ((0, 170), (-1, 170), (68, 0), (68, -1)):
            with self.subTest(weight=weight, height=height):
                with self.assertRaises(ValueError):
                    calculate_bmi(weight, height)

    def test_rejects_non_finite_values(self):
        for weight, height in ((float("nan"), 170), (68, float("inf"))):
            with self.subTest(weight=weight, height=height):
                with self.assertRaises(ValueError):
                    calculate_bmi(weight, height)

    def test_categories_and_boundaries(self):
        self.assertEqual(bmi_category(18.49), "體重過輕")
        self.assertEqual(bmi_category(18.5), "健康體重")
        self.assertEqual(bmi_category(24), "體重過重")
        self.assertEqual(bmi_category(27), "肥胖")


if __name__ == "__main__":
    unittest.main()
