
import math

# ============================================================
# CONFIG
# ============================================================

INPUT_FILE = r"D:\testcase\DATA\OFM\output_3.txt"
OUTPUT_FILE = "silu_output3.txt"

# Số chữ số sau dấu phẩy khi lưu
DECIMAL_DIGITS = 8


# ============================================================
# SiLU
# ============================================================

def sigmoid(x):
    return 1.0 / (1.0 + math.exp(-x))


def silu(x):
    return x * sigmoid(x)


# ============================================================
# ĐỌC MẢNG 2D TỪ FILE TXT
# ============================================================

def read_2d_array(filename):
    array_2d = []

    with open(filename, "r") as f:
        for line in f:
            line = line.strip()

            # Bỏ qua dòng trống
            if not line:
                continue

            # Hỗ trợ cách nhau bằng space
            values = line.split()

            row = [float(value) for value in values]

            array_2d.append(row)

    return array_2d


# ============================================================
# TÍNH SILU CHO TOÀN BỘ MẢNG
# ============================================================

def calculate_silu(array_2d):
    silu_array = []

    for row in array_2d:
        silu_row = []

        for x in row:
            y = silu(x)
            silu_row.append(y)

        silu_array.append(silu_row)

    return silu_array


# ============================================================
# GHI MẢNG 2D RA FILE TXT
# ============================================================

def write_2d_array(filename, array_2d):

    with open(filename, "w") as f:

        for row in array_2d:

            line = " ".join(
                f"{value:.{DECIMAL_DIGITS}f}"
                for value in row
            )

            f.write(line + "\n")


# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":

    # Đọc input
    input_array = read_2d_array(INPUT_FILE)

    print("Kich thuoc mang:")
    print("So hang =", len(input_array))
    print("So cot  =", len(input_array[0]))

    # Tính SiLU
    output_array = calculate_silu(input_array)

    # Ghi kết quả
    write_2d_array(OUTPUT_FILE, output_array)

    print()
    print("Da tinh SiLU xong!")
    print("File output:", OUTPUT_FILE)

