import torch
import torch.nn as nn
from torchvision import transforms
from PIL import Image
import os
import numpy as np

# 1. LOAD MODEL

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

    def forward(self, x):

        x = self.conv1(x)
        x = self.relu1(x)
        x = self.pool1(x)

        x = self.conv2(x)
        x = self.relu2(x)
        x = self.pool2(x)

        x = x.view(x.size(0), -1)

        x = self.fc1(x)
        x = self.relu3(x)

        x = self.fc2(x)
        x = self.relu4(x)

        x = self.fc3(x)

        return x

# 2. LOAD TRAINED WEIGHT

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

# 3. LOAD ONE IMAGE

image_path = r"D:\testcase\data_sheet\test\cat\cat_test.png"

transform = transforms.Compose([
    transforms.Resize((128, 128)),
    transforms.ToTensor()
])

image = Image.open(
    image_path
).convert("RGB")

image = transform(image)

# Add batch dimension
image = image.unsqueeze(0)

image = image.to(device)


# 4. CREATE OUTPUT FOLDERS

os.makedirs(
    "output/conv1",
    exist_ok=True
)

os.makedirs(
    "output/conv2",
    exist_ok=True
)

# 5. SAVE FUNCTION

def save_tensor(
    tensor,
    filename
):

    tensor = tensor.detach().cpu().numpy()

    np.savetxt(
        filename,
        tensor.flatten(),
        fmt="%.8f"
    )

    print(
        "Saved:",
        filename
    )

# 6. RUN NETWORK STEP BY STEP

with torch.no_grad():

    # INPUT IMAGE

    save_tensor(
        image,
        "output/input_image.txt"
    )

    print(
        "Input shape:",
        image.shape
    )


    # CONV1

    conv1_output = model.conv1(
        image
    )

    save_tensor(
        conv1_output,
        "output/conv1/conv1_output.txt"
    )

    print(
        "Conv1 output shape:",
        conv1_output.shape
    )

    # RELU1

    relu1_output = model.relu1(
        conv1_output
    )

    save_tensor(
        relu1_output,
        "output/conv1/relu_output.txt"
    )

    print(
        "ReLU1 output shape:",
        relu1_output.shape
    )

    # POOL1

    pool1_output = model.pool1(
        relu1_output
    )

    save_tensor(
        pool1_output,
        "output/conv1/pool_output.txt"
    )

    print(
        "Pool1 output shape:",
        pool1_output.shape
    )

    # CONV2

    conv2_output = model.conv2(
        pool1_output
    )

    save_tensor(
        conv2_output,
        "output/conv2/conv2_output.txt"
    )

    print(
        "Conv2 output shape:",
        conv2_output.shape
    )

    # RELU2

    relu2_output = model.relu2(
        conv2_output
    )

    save_tensor(
        relu2_output,
        "output/conv2/relu_output.txt"
    )

    print(
        "ReLU2 output shape:",
        relu2_output.shape
    )

    # POOL2

    pool2_output = model.pool2(
        relu2_output
    )

    save_tensor(
        pool2_output,
        "output/conv2/pool_output.txt"
    )

    print(
        "Pool2 output shape:",
        pool2_output.shape
    )


print("\nEXPORT COMPLETED!")