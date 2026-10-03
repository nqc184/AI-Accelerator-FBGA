import os
import torch
import torch.nn as nn
import torch.optim as optim

from torchvision import datasets, transforms
from torch.utils.data import DataLoader

DATA_DIR = "data"
OUTPUT_DIR = "output"

IMAGE_SIZE = 128
BATCH_SIZE = 16
EPOCHS = 50
LEARNING_RATE = 0.001

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

print("========================================")
print("LeNet-5 Cat/Dog Training")
print("========================================")
print(f"Device: {DEVICE}")

if torch.cuda.is_available():
    print(f"GPU: {torch.cuda.get_device_name(0)}")

print("========================================")

train_transform = transforms.Compose([
    transforms.Grayscale(num_output_channels=1),
    transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
    transforms.RandomHorizontalFlip(),
    transforms.RandomRotation(10),
    transforms.ToTensor(),
    transforms.Normalize((0.5,), (0.5,))
])

test_transform = transforms.Compose([
    transforms.Grayscale(num_output_channels=1),
    transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
    transforms.ToTensor(),
    transforms.Normalize((0.5,), (0.5,))
])

train_dataset = datasets.ImageFolder(
    root=os.path.join(DATA_DIR, "train"),
    transform=train_transform
)

test_dataset = datasets.ImageFolder(
    root=os.path.join(DATA_DIR, "test"),
    transform=test_transform
)

print(f"Train images: {len(train_dataset)}")
print(f"Test images : {len(test_dataset)}")

print(f"Classes: {train_dataset.classes}")
print(f"Class mapping: {train_dataset.class_to_idx}")

train_loader = DataLoader(
    train_dataset,
    batch_size=BATCH_SIZE,
    shuffle=True,
    num_workers=2,
    pin_memory=True
)

test_loader = DataLoader(
    test_dataset,
    batch_size=BATCH_SIZE,
    shuffle=False,
    num_workers=2,
    pin_memory=True
)

class LeNet5(nn.Module):

    def __init__(self):
        super().__init__()

        self.conv1 = nn.Conv2d(
            in_channels=1,
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

        x = torch.flatten(x, 1)

        x = self.fc1(x)
        x = self.relu3(x)

        x = self.fc2(x)
        x = self.relu4(x)

        x = self.fc3(x)

        return x

model = LeNet5().to(DEVICE)

print("\nModel:")
print(model)

criterion = nn.CrossEntropyLoss()

optimizer = optim.Adam(
    model.parameters(),
    lr=LEARNING_RATE
)

print("\n========================================")
print("Starting training...")
print("========================================")

for epoch in range(EPOCHS):

    model.train()

    running_loss = 0.0
    correct = 0
    total = 0

    for images, labels in train_loader:

        images = images.to(
            DEVICE,
            non_blocking=True
        )

        labels = labels.to(
            DEVICE,
            non_blocking=True
        )

        optimizer.zero_grad()

        outputs = model(images)

        loss = criterion(
            outputs,
            labels
        )

        loss.backward()

        optimizer.step()

        running_loss += loss.item()

        _, predicted = torch.max(
            outputs,
            1
        )

        total += labels.size(0)

        correct += (
            predicted == labels
        ).sum().item()

    train_accuracy = 100.0 * correct / total

    average_loss = (
        running_loss / len(train_loader)
    )

    print(
        f"Epoch [{epoch + 1:02d}/{EPOCHS}] "
        f"Loss: {average_loss:.6f} "
        f"Train Accuracy: {train_accuracy:.2f}%"
    )

os.makedirs(
    OUTPUT_DIR,
    exist_ok=True
)

model_path = os.path.join(
    OUTPUT_DIR,
    "lenet5_cat_dog.pth"
)

torch.save(
    model.state_dict(),
    model_path
)

print("\nModel saved:")
print(model_path)

model.eval()

correct = 0
total = 0

print("\n========================================")
print("Testing")
print("========================================")

with torch.no_grad():

    for images, labels in test_loader:

        images = images.to(DEVICE)
        labels = labels.to(DEVICE)

        outputs = model(images)

        _, predicted = torch.max(
            outputs,
            1
        )

        total += labels.size(0)

        correct += (
            predicted == labels
        ).sum().item()

test_accuracy = 100.0 * correct / total

print(
    f"Test Accuracy: "
    f"{test_accuracy:.2f}%"
)

print("========================================")
print("Training completed.")
print("========================================")