import os
import torch
import torch.nn as nn
import matplotlib.pyplot as plt
from torchvision import datasets, transforms
from torch.utils.data import DataLoader


# ============================================================
# PATH
# ============================================================

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, "data")
MODEL_PATH = os.path.join(BASE_DIR, "output", "lenet5_cat_dog.pth")


# ============================================================
# DEVICE
# ============================================================

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

print("Device:", device)


# ============================================================
# TRANSFORM
# ============================================================

transform = transforms.Compose([
    transforms.Grayscale(num_output_channels=1),
    transforms.Resize((128, 128)),
    transforms.ToTensor(),
    transforms.Normalize((0.5,), (0.5,))
])


# ============================================================
# DATASET
# ============================================================

test_dataset = datasets.ImageFolder(
    root=os.path.join(DATA_DIR, "test"),
    transform=transform
)

test_loader = DataLoader(
    test_dataset,
    batch_size=5,
    shuffle=False
)

print("Classes:", test_dataset.classes)
print("Number of test images:", len(test_dataset))


# ============================================================
# LENET-5
# ============================================================

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

        self.fc1 = nn.Linear(16 * 29 * 29, 120)
        self.fc2 = nn.Linear(120, 84)
        self.fc3 = nn.Linear(84, 2)

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


# ============================================================
# LOAD MODEL
# ============================================================

model = LeNet5().to(device)

model.load_state_dict(
    torch.load(MODEL_PATH, map_location=device)
)

model.eval()

print("Model loaded successfully.")


# ============================================================
# PREDICTION
# ============================================================

images, labels = next(iter(test_loader))

images = images.to(device)
labels = labels.to(device)

with torch.no_grad():

    outputs = model(images)

    probabilities = torch.softmax(outputs, dim=1)

    predictions = torch.argmax(outputs, dim=1)


# ============================================================
# DISPLAY RESULTS
# ============================================================

plt.figure(figsize=(15, 8))

for i in range(len(images)):

    image = images[i].cpu().squeeze(0)

    # Undo Normalize for displaying
    image = image * 0.5 + 0.5

    true_label = test_dataset.classes[labels[i].item()]
    predicted_label = test_dataset.classes[predictions[i].item()]

    confidence = probabilities[i][predictions[i]].item() * 100

    plt.subplot(2, 3, i + 1)

    plt.imshow(image, cmap="gray")

    if true_label == predicted_label:
        result = "CORRECT"
    else:
        result = "WRONG"

    plt.title(
        f"True: {true_label}\n"
        f"Pred: {predicted_label} ({confidence:.2f}%)\n"
        f"{result}"
    )

    plt.axis("off")


plt.tight_layout()
plt.show()
