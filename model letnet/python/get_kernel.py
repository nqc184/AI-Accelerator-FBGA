import torch
import torch.nn as nn
import numpy as np
import os

# 1. DEFINE MODEL

class LeNet(nn.Module):

    def __init__(self):
        super(LeNet, self).__init__()

        self.conv1 = nn.Conv2d(
            in_channels=3,
            out_channels=6,
            kernel_size=5
        )

        self.relu1 = nn.ReLU()

        self.pool1 = nn.MaxPool2d(
            kernel_size=2,
            stride=2
        )

        self.conv2 = nn.Conv2d(
            in_channels=6,
            out_channels=16,
            kernel_size=5
        )

        self.relu2 = nn.ReLU()

        self.pool2 = nn.MaxPool2d(
            kernel_size=2,
            stride=2
        )

        self.fc1 = nn.Linear(
            16 * 29 * 29,
            120
        )

        self.relu3 = nn.ReLU()

        self.fc2 = nn.Linear(
            120,
            84
        )

        self.relu4 = nn.ReLU()

        self.fc3 = nn.Linear(
            84,
            2
        )

# 2. LOAD MODEL

device = torch.device("cpu")

model = LeNet()

model.load_state_dict(
    torch.load(
        "lenet_cat_dog.pth",
        map_location=device
    )
)

model.to(device)

model.eval()

# 3. CREATE OUTPUT FOLDER

os.makedirs(
    "output/weights",
    exist_ok=True
)

# 4. GET CONV1 WEIGHT AND BIAS

conv1_weight = (
    model.conv1.weight
    .detach()
    .cpu()
    .numpy()
)

conv1_bias = (
    model.conv1.bias
    .detach()
    .cpu()
    .numpy()
)


print(
    "Conv1 weight shape:",
    conv1_weight.shape
)

print(
    "Conv1 bias shape:",
    conv1_bias.shape
)

# 5. EXPORT WEIGHT

for out_channel in range(6):

    weight_R = conv1_weight[
        out_channel,
        0
    ]

    weight_G = conv1_weight[
        out_channel,
        1
    ]

    weight_B = conv1_weight[
        out_channel,
        2
    ]

    np.savetxt(
        f"output/weights/filter{out_channel}_R.txt",
        weight_R.flatten(),
        fmt="%.8f"
    )

    np.savetxt(
        f"output/weights/filter{out_channel}_G.txt",
        weight_G.flatten(),
        fmt="%.8f"
    )

    np.savetxt(
        f"output/weights/filter{out_channel}_B.txt",
        weight_B.flatten(),
        fmt="%.8f"
    )


# 6. EXPORT BIAS

np.savetxt(
    "output/weights/bias.txt",
    conv1_bias,
    fmt="%.8f"
)


print()
print("Export completed!")