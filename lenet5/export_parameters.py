import torch
import numpy as np
from pathlib import Path
from PIL import Image

# ==============================
# CONFIGURATION
# ==============================

BASE_DIR = Path(__file__).resolve().parent
CHECKPOINT = BASE_DIR / "checkpoints" / "lenet_rgb_best.pth"
DATA_DIR = BASE_DIR / "data"
EXPORT_DIR = BASE_DIR / "rtl_data"

EXPORT_DIR.mkdir(exist_ok=True)

DATA_WIDTH = 24
FRAC_BITS = 16

# ==============================
# LOAD TRAINED MODEL
# ==============================

checkpoint = torch.load(
    CHECKPOINT,
    map_location="cpu",
    weights_only=False
)

state_dict = checkpoint["model_state_dict"]

# ==============================
# FIXED-POINT CONVERSION
# Q8.16: 24-bit signed
# ==============================

def to_fixed(value, frac_bits=16, width=24):
    scale = 1 << frac_bits
    integer = int(np.round(float(value) * scale))

    minimum = -(1 << (width - 1))
    maximum = (1 << (width - 1)) - 1

    integer = max(minimum, min(maximum, integer))

    return integer & ((1 << width) - 1)


def save_hex(filename, values, width):
    digits = (width + 3) // 4

    with open(filename, "w") as f:
        for value in values:
            f.write(f"{int(value):0{digits}X}\n")


# ==============================
# EXPORT CONV WEIGHTS
# ==============================

for layer_name in ["conv1", "conv2"]:

    weights = state_dict[f"{layer_name}.weight"].numpy()
    biases = state_dict[f"{layer_name}.bias"].numpy()

    # PyTorch order:
    # [output_channel][input_channel][kernel_y][kernel_x]

    weight_fixed = [
        to_fixed(value)
        for value in weights.flatten()
    ]

    # Input and weight are Q8.16.
    # Product is Q16.32.
    # Therefore bias is converted to Q16.32 (48-bit).
    bias_fixed = [
        to_fixed(value, frac_bits=32, width=48)
        for value in biases
    ]

    save_hex(
        EXPORT_DIR / f"{layer_name}_weight.mem",
        weight_fixed,
        24
    )

    save_hex(
        EXPORT_DIR / f"{layer_name}_bias.mem",
        bias_fixed,
        48
    )

    print(f"{layer_name}:")
    print("Weight shape:", weights.shape)
    print("Bias shape:", biases.shape)


# ==============================
# EXPORT RGB INPUT IMAGE
# ==============================

# Chọn một ảnh test, ví dụ ảnh mèo đầu tiên.
cat_folder = DATA_DIR / "test" / "cat"

image_files = [
    p for p in cat_folder.iterdir()
    if p.suffix.lower() in [".jpg", ".jpeg", ".png", ".bmp"]
]

if not image_files:
    raise FileNotFoundError("No cat image found in test/cat")

image_path = image_files[0]

image = Image.open(image_path).convert("RGB")
image = image.resize((128, 128))

# Convert [H, W, RGB] to [RGB, H, W]
image_array = np.asarray(image, dtype=np.float32) / 255.0
image_array = np.transpose(image_array, (2, 0, 1))

for channel, name in enumerate(["R", "G", "B"]):

    channel_data = image_array[channel].flatten()

    channel_fixed = [
        to_fixed(value)
        for value in channel_data
    ]

    save_hex(
        EXPORT_DIR / f"ifm_{name}.mem",
        channel_fixed,
        24
    )

print("\nExport completed!")
print("Image:", image_path)
print("Output directory:", EXPORT_DIR)