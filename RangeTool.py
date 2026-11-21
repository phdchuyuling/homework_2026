"""數值上下限計算工具（CLI）

輸入標準值與差值，自動計算允許的上下限範圍。
所有數值使用 decimal.Decimal 處理，並統一顯示到小數點後三位。
僅使用 Python 標準函式庫。
"""

import re
import sys
from decimal import Decimal, InvalidOperation, ROUND_DOWN

DECIMAL_PLACES = 3
QUANT = Decimal("0.001")
LINE = "=" * 32
THIN_LINE = "-" * 32

MODE_SAME = "1"
MODE_DIFF = "2"
MODE_NAMES = {MODE_SAME: "上下限差值相同", MODE_DIFF: "上下限差值不同"}


# ---------------------------------------------------------------------------
# 數值處理
# ---------------------------------------------------------------------------

def accept_char(buffer, ch, allow_negative):
    """判斷在目前的輸入內容 buffer 後面，是否接受字元 ch。

    規則：
    - 數字：若小數部分已有三位，則忽略。
    - 小數點：整個數字只能有一個。
    - 負號：只能出現在開頭，且需允許負數。
    """
    if ch.isdigit() and ch.isascii():
        if "." in buffer:
            decimals = buffer.split(".", 1)[1]
            return len(decimals) < DECIMAL_PLACES
        return True
    if ch == ".":
        return "." not in buffer
    if ch == "-":
        return allow_negative and buffer == ""
    return False


def truncate_text(text, allow_negative):
    """將整段文字（非互動模式時使用）依相同規則過濾。

    若含有不合法字元則回傳 None；超過三位的小數直接截掉。
    """
    text = text.strip()
    # 負號一律先接受，是否允許負數交由 ask_number 判斷並給出明確提示
    if not re.fullmatch(r"-?\d*\.?\d*", text):
        return None
    if "." in text:
        integer, decimals = text.split(".", 1)
        text = integer + "." + decimals[:DECIMAL_PLACES]
    return text


def parse_decimal(text):
    """將文字轉為三位小數的 Decimal；無效時回傳 None。"""
    if text is None or text in ("", "-", ".", "-."):
        return None
    try:
        value = Decimal(text)
    except InvalidOperation:
        return None
    value = value.quantize(QUANT, rounding=ROUND_DOWN)
    if value == 0:
        value = Decimal("0.000")  # 避免出現 -0.000
    return value


def fmt(value):
    """將 Decimal 格式化為三位小數字串。"""
    value = value.quantize(QUANT, rounding=ROUND_DOWN)
    if value == 0:
        value = Decimal("0.000")
    return f"{value:.{DECIMAL_PLACES}f}"


def calculate(standard, upper_range, lower_range):
    """回傳 (下限, 上限)。"""
    lower = standard - lower_range
    upper = standard + upper_range
    # 差值皆 >= 0，理論上不會顛倒；保險起見仍做排序。
    return min(lower, upper), max(lower, upper)


# ---------------------------------------------------------------------------
# 逐字元輸入（限制小數位數）
# ---------------------------------------------------------------------------

def _read_key_windows():
    import msvcrt

    ch = msvcrt.getwch()
    if ch in ("\x00", "\xe0"):  # 方向鍵等特殊鍵：讀掉第二個字元後忽略
        msvcrt.getwch()
        return ""
    return ch


def _make_unix_reader():
    import termios
    import tty

    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)

    def read_key():
        try:
            tty.setraw(fd)
            ch = sys.stdin.read(1)
            if ch == "\x1b":  # 方向鍵等跳脫序列：讀掉並忽略
                import select
                while select.select([sys.stdin], [], [], 0.01)[0]:
                    sys.stdin.read(1)
                return ""
            return ch
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old)

    return read_key


def _get_key_reader():
    if sys.platform == "win32":
        return _read_key_windows
    return _make_unix_reader()


def read_limited(prompt, allow_negative):
    """逐字元讀取數字輸入，超過三位小數的字元會被直接忽略。

    支援 Backspace 刪除與 Enter 確認。若非互動終端機（例如管線輸入），
    則改用一般 input() 並套用相同的截斷規則。
    """
    if not sys.stdin.isatty():
        text = input(prompt)
        return truncate_text(text, allow_negative)

    read_key = _get_key_reader()
    sys.stdout.write(prompt)
    sys.stdout.flush()
    buffer = ""
    while True:
        ch = read_key()
        if ch in ("\r", "\n"):
            sys.stdout.write("\n")
            sys.stdout.flush()
            return buffer
        if ch == "\x03":  # Ctrl+C
            sys.stdout.write("\n")
            raise KeyboardInterrupt
        if ch in ("\x08", "\x7f"):  # Backspace
            if buffer:
                buffer = buffer[:-1]
                sys.stdout.write("\b \b")
                sys.stdout.flush()
            continue
        if ch and accept_char(buffer, ch, allow_negative):
            buffer += ch
            sys.stdout.write(ch)
            sys.stdout.flush()


def ask_number(prompt, allow_negative):
    """重複詢問直到取得有效數字。"""
    while True:
        value = parse_decimal(read_limited(prompt, allow_negative))
        if value is None:
            print("輸入無效，請輸入有效的數字。")
            continue
        if not allow_negative and value < 0:
            print("差值必須大於或等於 0，請重新輸入。")
            continue
        return value


def ask_choice(prompt, choices):
    """重複詢問直到輸入為 choices 其中之一。"""
    while True:
        answer = input(prompt).strip()
        if answer in choices:
            return answer
        print(f"輸入無效，請輸入 {' 或 '.join(choices)}。")


# ---------------------------------------------------------------------------
# 主流程
# ---------------------------------------------------------------------------

def show_result(standard, mode, upper_range, lower_range, lower, upper):
    print()
    print(LINE)
    print("       數值上下限計算結果")
    print(LINE)
    print()
    print(f"標準值：{fmt(standard)}")
    print()
    print(f"計算模式：{MODE_NAMES[mode]}")
    print()
    if mode == MODE_SAME:
        print(f"差值：{fmt(upper_range)}")
    else:
        print(f"上限差值：{fmt(upper_range)}")
        print(f"下限差值：{fmt(lower_range)}")
    print()
    print(THIN_LINE)
    print(f"下限：{fmt(lower)}")
    print(f"上限：{fmt(upper)}")
    print()
    print(f"允許範圍：{fmt(lower)} ～ {fmt(upper)}")
    print(LINE)
    print()


def run_once():
    standard = ask_number("請輸入標準值：", allow_negative=True)
    print(f"標準值：{fmt(standard)}")
    print()
    print("請選擇計算模式：")
    print("1. 上下限差值相同")
    print("2. 上下限差值不同")
    mode = ask_choice("請輸入選項（1/2）：", (MODE_SAME, MODE_DIFF))

    if mode == MODE_SAME:
        upper_range = lower_range = ask_number("請輸入差值（Range）：", allow_negative=False)
    else:
        upper_range = ask_number("請輸入上限差值（Upper Range）：", allow_negative=False)
        lower_range = ask_number("請輸入下限差值（Lower Range）：", allow_negative=False)

    lower, upper = calculate(standard, upper_range, lower_range)
    show_result(standard, mode, upper_range, lower_range, lower, upper)


def main():
    print("數值上下限計算工具")
    print()
    try:
        while True:
            run_once()
            print("是否繼續計算？")
            print("1. 重新計算")
            print("2. 結束程式")
            if ask_choice("請輸入選項（1/2）：", ("1", "2")) == "2":
                break
            print()
    except (KeyboardInterrupt, EOFError):
        print()
    print("程式結束，謝謝使用！")


if __name__ == "__main__":
    main()
