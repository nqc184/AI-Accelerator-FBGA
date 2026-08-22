import os
import numpy as np

INPUT_FILE = r"D:\testcase\output\input_image.txt"

OUTPUT_DIR = "output/rgb_channels"

os.makedirs(
    OUTPUT_DIR,
    exist_ok=True
)

data = np.loadtxt(
    INPUT_FILE
)

print("Total values:", len(data))

if len(data) != 49152:
    raise ValueError(
        f"Expected 49152 values, got {len(data)}"
    )

R = data[0:16384]

G = data[16384:32768]

B = data[32768:49152]

np.savetxt(
    f"{OUTPUT_DIR}/R.txt",
    R,
    fmt="%.8f"
)

np.savetxt(
    f"{OUTPUT_DIR}/G.txt",
    G,
    fmt="%.8f"
)

np.savetxt(
    f"{OUTPUT_DIR}/B.txt",
    B,
    fmt="%.8f"
)

print("R values:", len(R))
print("G values:", len(G))
print("B values:", len(B))

print("RGB split completed!")