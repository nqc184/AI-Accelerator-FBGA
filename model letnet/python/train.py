import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader
from torchvision import datasets, transforms
import matplotlib.pyplot as plt

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

print("Device:", device)

transform = transforms.Compose([
    transforms.Resize((128, 128)),
    transforms.ToTensor()
])

train_dataset = datasets.ImageFolder(
    root=r"D:\testcase\data_sheet\train",
    transform=transform
)

test_dataset = datasets.ImageFolder(
    root=r"D:\testcase\data_sheet\test",
    transform=transform
)

train_loader = DataLoader(
    train_dataset,
    batch_size=4,
    shuffle=True
)

test_loader = DataLoader(
    test_dataset,
    batch_size=1,
    shuffle=False
)

print("Classes:", train_dataset.classes)
print("Train images:", len(train_dataset))
print("Test images:", len(test_dataset))


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


model = LeNet().to(device)

criterion = nn.CrossEntropyLoss()

optimizer = optim.Adam(
    model.parameters(),
    lr=0.001
)

epochs = 50


for epoch in range(epochs):

    model.train()

    running_loss = 0.0
    correct = 0
    total = 0

    for images, labels in train_loader:

        images = images.to(device)
        labels = labels.to(device)

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

    accuracy = 100 * correct / total

    print(
        f"Epoch [{epoch + 1}/{epochs}] "
        f"Loss: {running_loss / len(train_loader):.4f} "
        f"Train Accuracy: {accuracy:.2f}%"
    )


torch.save(
    model.state_dict(),
    "lenet_cat_dog.pth"
)

print("\nModel saved: lenet_cat_dog.pth")


model.eval()

correct = 0
total = 0

images_to_show = []
labels_to_show = []
predictions_to_show = []


with torch.no_grad():

    for images, labels in test_loader:

        images = images.to(device)
        labels = labels.to(device)

        outputs = model(images)

        _, predicted = torch.max(
            outputs,
            1
        )

        total += labels.size(0)

        correct += (
            predicted == labels
        ).sum().item()

        images_to_show.append(
            images.cpu()
        )

        labels_to_show.append(
            labels.item()
        )

        predictions_to_show.append(
            predicted.item()
        )


test_accuracy = 100 * correct / total

print(
    f"\nTest Accuracy: "
    f"{test_accuracy:.2f}%"
)


for i in range(len(images_to_show)):

    image = images_to_show[i][0]

    image = image.permute(
        1,
        2,
        0
    )

    true_label = train_dataset.classes[
        labels_to_show[i]
    ]

    predicted_label = train_dataset.classes[
        predictions_to_show[i]
    ]

    plt.figure(figsize=(5, 5))

    plt.imshow(image)

    plt.title(
        f"True: {true_label}\n"
        f"Predicted: {predicted_label}"
    )

    plt.axis("off")

    plt.show()