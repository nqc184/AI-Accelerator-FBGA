import os
import torch
import torch.nn as nn
import matplotlib.pyplot as plt
import numpy as np

from PIL import Image
from torchvision import datasets, transforms

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

DATA_DIR = os.path.join(BASE_DIR, "data")
MODEL_PATH = os.path.join(
    BASE_DIR,
    "output",
    "lenet5_cat_dog.pth"
)

OUTPUT_DIR = os.path.join(
    BASE_DIR,
    "output",
    "inspect"
)

os.makedirs(OUTPUT_DIR, exist_ok=True)

device = torch.device(
    "cuda" if torch.cuda.is_available() else "cpu"
)

print("Device:", device)

class LeNet5(nn.Module):

    def __init__(self):

        super().__init__()

        self.conv1 = nn.Conv2d(
            in_channels=1,
            out_channels=6,
            kernel_size=5
        )

        self.pool = nn.MaxPool2d(2, 2)

        self.conv2 = nn.Conv2d(
            in_channels=6,
            out_channels=16,
            kernel_size=5
        )

        self.fc1 = nn.Linear(
            16 * 29 * 29,
            120
        )

        self.fc2 = nn.Linear(
            120,
            84
        )

        self.fc3 = nn.Linear(
            84,
            2
        )

        self.relu = nn.ReLU()

    def forward(self, x):

        x = self.relu(self.conv1(x))
        x = self.pool(x)

        x = self.relu(self.conv2(x))
        x = self.pool(x)

        x = torch.flatten(x, 1)

        x = self.relu(self.fc1(x))
        x = self.relu(self.fc2(x))

        x = self.fc3(x)

        return x

model = LeNet5().to(device)

model.load_state_dict(
    torch.load(
        MODEL_PATH,
        map_location=device
    )
)

model.eval()

print("Model loaded.")

test_root = os.path.join(
    DATA_DIR,
    "test"
)

test_dataset = datasets.ImageFolder(
    root=test_root
)

# First image
image_path, label = test_dataset.samples[0]

print()
print("========================================")
print("FIRST TEST IMAGE")
print("========================================")
print("Path :", image_path)
print("Label:", test_dataset.classes[label])

original_image = Image.open(
    image_path
).convert("RGB")

print(
    "Original image size:",
    original_image.size
)

gray_image = original_image.convert("L")

gray_image = gray_image.resize(
    (128, 128)
)

image_tensor = transforms.ToTensor()(
    gray_image
)

input_tensor = transforms.Normalize(
    (0.5,),
    (0.5,)
)(
    image_tensor
)

input_tensor = input_tensor.unsqueeze(0)

input_tensor = input_tensor.to(device)


print(
    "Input tensor shape:",
    input_tensor.shape
)

rgb_array = np.array(original_image)

np.savetxt(
    os.path.join(
        OUTPUT_DIR,
        "image_rgb_R.txt"
    ),
    rgb_array[:, :, 0],
    fmt="%.0f"
)

np.savetxt(
    os.path.join(
        OUTPUT_DIR,
        "image_rgb_G.txt"
    ),
    rgb_array[:, :, 1],
    fmt="%.0f"
)

np.savetxt(
    os.path.join(
        OUTPUT_DIR,
        "image_rgb_B.txt"
    ),
    rgb_array[:, :, 2],
    fmt="%.0f"
)


gray_array = np.array(gray_image)

np.savetxt(
    os.path.join(
        OUTPUT_DIR,
        "image_gray_128x128.txt"
    ),
    gray_array,
    fmt="%.0f"
)

normalized_array = input_tensor[0, 0].detach().cpu().numpy()

np.savetxt(
    os.path.join(
        OUTPUT_DIR,
        "image_input_normalized.txt"
    ),
    normalized_array,
    fmt="%.8f"
)


conv1_weight = model.conv1.weight.detach().cpu().numpy()
conv1_bias = model.conv1.bias.detach().cpu().numpy()

conv2_weight = model.conv2.weight.detach().cpu().numpy()
conv2_bias = model.conv2.bias.detach().cpu().numpy()


print()
print("========================================")
print("WEIGHTS")
print("========================================")

print(
    "Conv1 weight:",
    conv1_weight.shape
)

print(
    "Conv1 bias:",
    conv1_bias.shape
)

print(
    "Conv2 weight:",
    conv2_weight.shape
)

print(
    "Conv2 bias:",
    conv2_bias.shape
)

for i in range(6):

    np.savetxt(
        os.path.join(
            OUTPUT_DIR,
            f"conv1_kernel_{i}.txt"
        ),
        conv1_weight[i, 0],
        fmt="%.8f"
    )


np.savetxt(
    os.path.join(
        OUTPUT_DIR,
        "conv1_bias.txt"
    ),
    conv1_bias,
    fmt="%.8f"
)

for i in range(16):

    for j in range(6):

        np.savetxt(
            os.path.join(
                OUTPUT_DIR,
                f"conv2_kernel_{i}_{j}.txt"
            ),
            conv2_weight[i, j],
            fmt="%.8f"
        )


np.savetxt(
    os.path.join(
        OUTPUT_DIR,
        "conv2_bias.txt"
    ),
    conv2_bias,
    fmt="%.8f"
)

with torch.no_grad():

    conv1_pre = model.conv1(input_tensor)

    conv1_post = model.relu(conv1_pre)

    pool1 = model.pool(conv1_post)

    conv2_pre = model.conv2(pool1)

    conv2_post = model.relu(conv2_pre)

print()
print("========================================")
print("INTERMEDIATE TENSORS")
print("========================================")

print(
    "Input       :",
    input_tensor.shape
)

print(
    "Conv1 pre   :",
    conv1_pre.shape
)

print(
    "Conv1 post  :",
    conv1_post.shape
)

print(
    "Pool1       :",
    pool1.shape
)

print(
    "Conv2 pre   :",
    conv2_pre.shape
)

print(
    "Conv2 post  :",
    conv2_post.shape
)

def save_feature_maps(
    tensor,
    prefix
):

    tensor = tensor[0].detach().cpu().numpy()

    for channel in range(tensor.shape[0]):

        np.savetxt(
            os.path.join(
                OUTPUT_DIR,
                f"{prefix}_{channel}.txt"
            ),
            tensor[channel],
            fmt="%.8f"
        )


save_feature_maps(
    conv1_pre,
    "conv1_pre_relu"
)

save_feature_maps(
    conv1_post,
    "conv1_post_relu"
)

save_feature_maps(
    pool1,
    "pool1"
)

save_feature_maps(
    conv2_pre,
    "conv2_pre_relu"
)

save_feature_maps(
    conv2_post,
    "conv2_post_relu"
)

plt.figure(figsize=(16, 12))

plt.subplot(3, 4, 1)

plt.imshow(original_image)

plt.title(
    "Original RGB"
)

plt.axis("off")

plt.subplot(3, 4, 2)

plt.imshow(
    gray_image,
    cmap="gray"
)

plt.title(
    "Gray 128×128"
)

plt.axis("off")

for i in range(6):

    plt.subplot(3, 4, i + 3)

    plt.imshow(
        conv1_pre[0, i].detach().cpu(),
        cmap="gray"
    )

    plt.title(
        f"Conv1[{i}] BEFORE ReLU"
    )

    plt.axis("off")


plt.tight_layout()

plt.savefig(
    os.path.join(
        OUTPUT_DIR,
        "conv1_before_relu.png"
    ),
    dpi=150
)

plt.show()

plt.figure(figsize=(12, 8))

for i in range(6):

    plt.subplot(2, 3, i + 1)

    plt.imshow(
        conv1_post[0, i].detach().cpu(),
        cmap="gray"
    )

    plt.title(
        f"Conv1[{i}] AFTER ReLU"
    )

    plt.axis("off")


plt.tight_layout()

plt.savefig(
    os.path.join(
        OUTPUT_DIR,
        "conv1_after_relu.png"
    ),
    dpi=150
)

plt.show()

plt.figure(figsize=(16, 10))

for i in range(16):

    plt.subplot(4, 4, i + 1)

    plt.imshow(
        conv2_pre[0, i].detach().cpu(),
        cmap="gray"
    )

    plt.title(
        f"Conv2[{i}] BEFORE ReLU"
    )

    plt.axis("off")


plt.tight_layout()

plt.savefig(
    os.path.join(
        OUTPUT_DIR,
        "conv2_before_relu.png"
    ),
    dpi=150
)

plt.show()

plt.figure(figsize=(16, 10))

for i in range(16):

    plt.subplot(4, 4, i + 1)

    plt.imshow(
        conv2_post[0, i].detach().cpu(),
        cmap="gray"
    )

    plt.title(
        f"Conv2[{i}] AFTER ReLU"
    )

    plt.axis("off")


plt.tight_layout()

plt.savefig(
    os.path.join(
        OUTPUT_DIR,
        "conv2_after_relu.png"
    ),
    dpi=150
)

plt.show()

plt.figure(figsize=(12, 4))

for i in range(6):

    plt.subplot(2, 3, i + 1)

    plt.imshow(
        conv1_weight[i, 0],
        cmap="gray"
    )

    plt.title(
        f"Conv1 Kernel {i}\nBias={conv1_bias[i]:.4f}"
    )

    plt.colorbar()

    plt.axis("off")


plt.tight_layout()

plt.savefig(
    os.path.join(
        OUTPUT_DIR,
        "conv1_kernels.png"
    ),
    dpi=150
)

plt.show()


print()
print("========================================")
print("DONE")
print("========================================")
print(
    "All data saved to:"
)
print(
    OUTPUT_DIR
)

