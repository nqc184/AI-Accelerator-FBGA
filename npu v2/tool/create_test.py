def decimal_to_q_hex(value, width_bits, frac_bits):
    scaled = round(value * (1 << frac_bits))
    max_val = (1 << (width_bits - 1)) - 1
    min_val = -(1 << (width_bits - 1))
    if scaled > max_val or scaled < min_val:
        raise ValueError(f"Gia tri {value} vuot pham vi Q{width_bits-frac_bits}.{frac_bits}")
    if scaled < 0:
        scaled += (1 << width_bits)
    hex_digits = width_bits // 4
    return format(scaled, f'0{hex_digits}X')


def convert_file(input_path, output_path, width_bits, frac_bits, scale=1.0):
    with open(input_path, 'r') as fin, open(output_path, 'w') as fout:
        for line_num, line in enumerate(fin, 1):
            line = line.strip()
            if not line:
                continue
            try:
                value = float(line) * scale
                hex_val = decimal_to_q_hex(value, width_bits, frac_bits)
                fout.write(hex_val + '\n')
            except ValueError as e:
                print(f"Loi dong {line_num} ('{line}'): {e}")
                raise


if __name__ == '__main__':
    convert_file(r'/home/thaituroblox/Desktop/AI-Accelerator-FBGA/npu v2/tool/IFM.mem', 'IFM.mem', width_bits=24, frac_bits=16, scale=0.1)
    convert_file(r'/home/thaituroblox/Desktop/AI-Accelerator-FBGA/npu v2/tool/WGT.mem', 'WGT.mem', width_bits=24, frac_bits=16, scale=0.1)
    convert_file(r'/home/thaituroblox/Desktop/AI-Accelerator-FBGA/npu v2/tool/BIAS.mem', 'BIAS.mem', width_bits=48, frac_bits=32, scale=0.1)
    print("Da tao xong IFM.mem, WGT.mem, BIAS.mem")