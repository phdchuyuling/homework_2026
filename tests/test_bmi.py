"""Run from the repository root with python -m unittest discover -s tests -v."""

import re
import subprocess
import sys
import unittest
from decimal import Decimal
from pathlib import Path


PROGRAM = Path(__file__).resolve().parents[1] / "BMI.py"


class BmiAcceptanceTests(unittest.TestCase):
    def run_bmi(self, weight, height):
        result = subprocess.run(
            [sys.executable, str(PROGRAM)],
            input=f"{weight}\n{height}\n",
            capture_output=True,
            text=True,
            timeout=5,
        )
        return result

    def test_valid_inputs(self):
        cases = [
            ("60", "170", "20.76"),
            ("45", "160", "17.58"),
            ("90", "180", "27.78"),
            ("62.5", "165", "22.96"),
            ("47.36", "160", "18.50"),
            ("64", "160", "25.00"),
            ("76.8", "160", "30.00"),
            ("100", "200", "25.00"),
        ]
        for weight, height, expected in cases:
            with self.subTest(weight=weight, height=height):
                result = self.run_bmi(weight, height)
                self.assertEqual(result.returncode, 0, result.stderr)
                match = re.search(r"BMI: ([0-9]+\.[0-9]{2})$", result.stdout)
                self.assertIsNotNone(match, result.stdout)
                actual = match.group(1)
                self.assertLessEqual(abs(Decimal(actual) - Decimal(expected)), Decimal("0.01"))
                self.assertEqual(actual, expected)
                print(f"PASS {weight!r} kg / {height!r} cm -> {result.stdout.strip()}")

    def test_invalid_inputs(self):
        cases = [
            ("", "170"), ("   ", "170"), ("abc", "170"),
            ("60", ""), ("60", "   "), ("60", "abc"),
            ("0", "170"), ("-1", "170"), ("60", "0"),
            ("60", "-170"), ("60kg", "170"), ("NaN", "170"),
            ("60", "Infinity"), ("1e999", "170"), ("60", "1e-200"),
            ("1e308", "1"), ("60", "1e200"),
        ]
        for weight, height in cases:
            with self.subTest(weight=weight, height=height):
                result = self.run_bmi(weight, height)
                self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
                self.assertEqual(result.stderr, "")
                self.assertIn("Error:", result.stdout)
                self.assertNotIn("BMI:", result.stdout)
                print(f"PASS {weight!r} kg / {height!r} cm -> {result.stdout.strip()}")
