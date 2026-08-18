 
import os
import numpy as np

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
TESTCASE_ROOT = os.path.join(SCRIPT_DIR, "..", "testcase", "common")
 
 
def fp16_to_hex(x):
    bits = np.frombuffer(np.float16(x).tobytes(), dtype=np.uint16)[0]
    return f"{bits:04x}"

def write_mem_file(path, hex_lines):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        for line in hex_lines:
            f.write(line + "\n")

def gen_fp16_adder_testcases():
    out_dir = os.path.join(TESTCASE_ROOT, "fp16_adder")
    cases = {
        "normal": [
            (1.0, 2.0),
            (3.25, 0.75),
            (-2.5, 4.0),
        ],
        "edge_same_exp": [
            (1.5, 1.5),
            (1.75, 1.75),
            (1.999, 1.999),
        ],
        "edge_cancellation": [
            (1.0, -0.999512),
            (100.0, -99.9375),
        ],
        "edge_large_exp_diff": [
            (1000.0, 0.001),
            (65504.0, 1.0),  
        ],
        "edge_zero": [
            (0.0, 5.5),
            (-3.25, 0.0),
            (0.0, 0.0),
        ],
    }
 
    for case_name, pairs in cases.items():
        input_lines = []
        golden_lines = []
        for a_val, b_val in pairs:
            a = np.float16(a_val)
            b = np.float16(b_val)
            golden = a + b 
 
            input_lines.append(f"{fp16_to_hex(a)} {fp16_to_hex(b)}")
            golden_lines.append(fp16_to_hex(golden))
 
        write_mem_file(os.path.join(out_dir, f"tc_{case_name}_input.mem"), input_lines)
        write_mem_file(os.path.join(out_dir, f"tc_{case_name}_golden.mem"), golden_lines)
 
    print(f"[OK] Đã sinh testcase fp16_adder tại: {out_dir}")

def gen_fp16_multiplier_testcases():
    out_dir = os.path.join(TESTCASE_ROOT, "fp16_multiplier")
 
    cases = {
        "normal": [
            (2.0, 3.0),
            (1.5, -2.0),
            (0.5, 0.5),
        ],
        "edge_overflow": [
            (60000.0, 2.0),
            (65504.0, 65504.0),
        ],
        "edge_underflow": [
            (0.00006103515625, 0.5),  
        ],
        "edge_zero": [
            (0.0, 12345.0),
            (-7.5, 0.0),
        ],
    }
 
    for case_name, pairs in cases.items():
        input_lines = []
        golden_lines = []
        for a_val, b_val in pairs:
            a = np.float16(a_val)
            b = np.float16(b_val)
            golden = a * b
 
            input_lines.append(f"{fp16_to_hex(a)} {fp16_to_hex(b)}")
            golden_lines.append(fp16_to_hex(golden))
 
        write_mem_file(os.path.join(out_dir, f"tc_{case_name}_input.mem"), input_lines)
        write_mem_file(os.path.join(out_dir, f"tc_{case_name}_golden.mem"), golden_lines)
 
    print(f"[OK] Đã sinh testcase fp16_multiplier tại: {out_dir}")
 
def gen_pe_testcases(num_cycles=8, seed=42):
    out_dir = os.path.join(TESTCASE_ROOT, "pe")
    rng = np.random.default_rng(seed)
 
    a_seq = rng.uniform(-4.0, 4.0, size=num_cycles).astype(np.float16)
    b_seq = rng.uniform(-4.0, 4.0, size=num_cycles).astype(np.float16)
 
    input_lines = []
    golden_lines = []
 
    acc = np.float16(0.0)
    for i in range(num_cycles):
        a = a_seq[i]
        b = b_seq[i]
        acc = np.float16(acc + np.float16(a * b))  
 
        input_lines.append(f"{fp16_to_hex(a)} {fp16_to_hex(b)}")
        golden_lines.append(fp16_to_hex(acc))  
 
    write_mem_file(os.path.join(out_dir, "tc_accumulate_seq_input.mem"), input_lines)
    write_mem_file(os.path.join(out_dir, "tc_accumulate_seq_golden.mem"), golden_lines)
 
    print(f"[OK] Đã sinh testcase pe (accumulate {num_cycles} chu kỳ) tại: {out_dir}")
 
 
if __name__ == "__main__":
    gen_fp16_adder_testcases()
    gen_fp16_multiplier_testcases()
    gen_pe_testcases()