import struct


def float_to_fp16_hex(value):
    """
    Convert Python float -> IEEE-754 FP16
    Return 4-digit hexadecimal string.
    """
    # Python struct 'e' = IEEE-754 binary16
    data = struct.pack(">e", value)
    value_uint16 = int.from_bytes(data, byteorder="big")

    return f"{value_uint16:04X}"


def fp16_hex_to_float(hex_value):
    """
    Convert 4-digit FP16 hex -> Python float
    """
    value_uint16 = int(hex_value, 16)
    data = value_uint16.to_bytes(2, byteorder="big")

    return struct.unpack(">e", data)[0]


def main():
    print("======================================")
    print("       FP16 MULTIPLICATION TEST")
    print("======================================")

    # Input
    a = float(input("Nhap so thu nhat  : "))
    b = float(input("Nhap so thu hai   : "))
    expected = float(input("Nhap expected     : "))

    # Calculation
    result = a * b

    # Convert to FP16 HEX
    a_hex = float_to_fp16_hex(a)
    b_hex = float_to_fp16_hex(b)
    expected_hex = float_to_fp16_hex(expected)
    result_hex = float_to_fp16_hex(result)

    # Print
    print("\n========== INPUT ==========")

    print(f"A        = {a}")
    print(f"A (FP16) = 0x{a_hex}")

    print(f"\nB        = {b}")
    print(f"B (FP16) = 0x{b_hex}")

    print(f"\nExpected        = {expected}")
    print(f"Expected (FP16) = 0x{expected_hex}")

    print("\n========== RESULT ==========")

    print(f"A * B            = {result}")
    print(f"A * B (FP16 HEX) = 0x{result_hex}")

    # Compare
    if result == expected:
        print("\nSTATUS: PASS")
    else:
        print("\nSTATUS: FAIL")
        print(f"Difference = {result - expected}")


if __name__ == "__main__":
    main()