import torch
import torch.nn as nn
import torch.optim as optim

from torchvision import datasets, transforms
from torch.utils.data import DataLoader, random_split

from pathlib import Path
import matplotlib.pyplot as plt
import random


# ==============================
# CONFIGURATION
# ==============================

BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = BASE_DIR / "data"
SAVE_DIR = BASE_DIR / "checkpoints"

SAVE_DIR.mkdir(exist_ok=True)

IMAGE_SIZE = 128
BATCH_SIZE = 32
EPOCHS = 50
LEARNING_RATE = 0.001

SEED = 42

torch.manual_seed(SEED)
random.seed(SEED)

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

print("Device:", device)


# ==============================
# TRANSFORMS
# ==============================

train_transform = transforms.Compose([
    transforms.Lambda(lambda img: img.convert("RGB")),
    transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
    transforms.RandomHorizontalFlip(p=0.5),
    transforms.ToTensor()
])

eval_transform = transforms.Compose([
    transforms.Lambda(lambda img: img.convert("RGB")),
    transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
    transforms.ToTensor()
])


# ==============================
# DATASET
# ==============================

full_dataset = datasets.ImageFolder(
    DATA_DIR / "train",
    transform=train_transform
)

test_dataset = datasets.ImageFolder(
    DATA_DIR / "test",
    transform=eval_transform
)

class_names = full_dataset.classes

print("Classes:", class_names)
print("Training images:", len(full_dataset))
print("Testing images:", len(test_dataset))

assert class_names == ["cat", "dog"], "Dataset must contain cat and dog folders."

generator = torch.Generator().manual_seed(SEED)

train_size = int(0.8 * len(full_dataset))
val_size = len(full_dataset) - train_size

train_dataset, val_dataset = random_split(
    full_dataset,
    [train_size, val_size],
    generator=generator
)

# Validation must not use random augmentation
val_dataset.dataset = datasets.ImageFolder(
    DATA_DIR / "train",
    transform=eval_transform
)

train_loader = DataLoader(
    train_dataset,
    batch_size=BATCH_SIZE,
    shuffle=True,
    num_workers=0
)

val_loader = DataLoader(
    val_dataset,
    batch_size=BATCH_SIZE,
    shuffle=False,
    num_workers=0
)

test_loader = DataLoader(
    test_dataset,
    batch_size=BATCH_SIZE,
    shuffle=False,
    num_workers=0
)


# ==============================
# LENET RGB MODEL
# ==============================

class LeNetRGB(nn.Module):

    def __init__(self):
        super(LeNetRGB, self).__init__()

        self.conv1 = nn.Conv2d(3, 6, kernel_size=5)
        self.relu1 = nn.ReLU()
        self.pool1 = nn.MaxPool2d(2, 2)

        self.conv2 = nn.Conv2d(6, 16, kernel_size=5)
        self.relu2 = nn.ReLU()
        self.pool2 = nn.MaxPool2d(2, 2)

        self.fc1 = nn.Linear(16 * 29 * 29, 120)
        self.fc2 = nn.Linear(120, 84)
        self.fc3 = nn.Linear(84, 2)

    def forward(self, x):

        x = self.conv1(x)
        x = self.relu1(x)
        x = self.pool1(x)

        x = self.conv2(x)
        x = self.relu2(x)
        x = self.pool2(x)

        x = torch.flatten(x, 1)

        x = self.fc1(x)
        x = self.fc2(x)
        x = self.fc3(x)

        return x


# ==============================
# INITIALIZE MODEL
# ==============================

model = LeNetRGB().to(device)

criterion = nn.CrossEntropyLoss()

optimizer = optim.Adam(
    model.parameters(),
    lr=LEARNING_RATE
)


# ==============================
# TRAINING
# ==============================

best_val_acc = -1.0

for epoch in range(EPOCHS):

    model.train()

    running_loss = 0.0
    correct = 0
    total = 0

    for images, labels in train_loader:

        images = images.to(device)
        labels = labels.to(device)

        optimizer.zero_grad()

        outputs = model(images)
        loss = criterion(outputs, labels)

        loss.backward()
        optimizer.step()

        running_loss += loss.item()

        _, predicted = torch.max(outputs, 1)

        total += labels.size(0)
        correct += (predicted == labels).sum().item()

    train_acc = 100 * correct / total
    train_loss = running_loss / len(train_loader)

    # Validation
    model.eval()

    val_correct = 0
    val_total = 0
    val_loss = 0.0

    with torch.no_grad():

        for images, labels in val_loader:

            images = images.to(device)
            labels = labels.to(device)

            outputs = model(images)

            loss = criterion(outputs, labels)

            val_loss += loss.item()

            _, predicted = torch.max(outputs, 1)

            val_total += labels.size(0)
            val_correct += (predicted == labels).sum().item()

    val_acc = 100 * val_correct / val_total
    val_loss = val_loss / len(val_loader)

    print(
        f"Epoch [{epoch+1}/{EPOCHS}] "
        f"Train Loss: {train_loss:.4f} "
        f"Train Acc: {train_acc:.2f}% "
        f"Val Loss: {val_loss:.4f} "
        f"Val Acc: {val_acc:.2f}%"
    )

    # Save best model
    if val_acc > best_val_acc:

        best_val_acc = val_acc

        torch.save({
            "model_state_dict": model.state_dict(),
            "class_names": class_names,
            "best_val_acc": best_val_acc
        }, SAVE_DIR / "lenet_rgb_best.pth")


# ==============================
# LOAD BEST MODEL
# ==============================

checkpoint = torch.load(
    SAVE_DIR / "lenet_rgb_best.pth",
    map_location=device,
    weights_only=False
)

model.load_state_dict(checkpoint["model_state_dict"])
model.eval()

print("\nBest Validation Accuracy:", checkpoint["best_val_acc"])


# ==============================
# TEST
# ==============================

test_correct = 0
test_total = 0

with torch.no_grad():

    for images, labels in test_loader:

        images = images.to(device)
        labels = labels.to(device)

        outputs = model(images)

        _, predicted = torch.max(outputs, 1)

        test_total += labels.size(0)
        test_correct += (predicted == labels).sum().item()

test_acc = 100 * test_correct / test_total

print(f"\nTest Accuracy: {test_acc:.2f}%")


# ==============================
# DISPLAY PREDICTION IMAGES
# ==============================

num_images = min(5, len(test_dataset))

fig, axes = plt.subplots(
    1,
    num_images,
    figsize=(5 * num_images, 5)
)

if num_images == 1:
    axes = [axes]

with torch.no_grad():

    for i in range(num_images):

        image, label = test_dataset[i]

        image_input = image.unsqueeze(0).to(device)

        output = model(image_input)

        probabilities = torch.softmax(output, dim=1)

        confidence, predicted = torch.max(probabilities, 1)

        image_show = image.permute(1, 2, 0).numpy()

        axes[i].imshow(image_show)

        axes[i].set_title(
            f"Actual: {class_names[label]}\n"
            f"Predict: {class_names[predicted.item()]}\n"
            f"Confidence: {confidence.item() * 100:.2f}%"
        )

        axes[i].axis("off")

plt.tight_layout()

plt.savefig(
    SAVE_DIR / "prediction_results.png",
    dpi=150
)

plt.show()

print("\nPrediction image saved to:", SAVE_DIR / "prediction_results.png")
print("Model saved to:", SAVE_DIR / "lenet_rgb_best.pth")