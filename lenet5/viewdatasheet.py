import os
import matplotlib.pyplot as plt
from torchvision import datasets, transforms
from torch.utils.data import DataLoader

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, "data")

transform = transforms.Compose([
    transforms.Grayscale(num_output_channels=1),
    transforms.Resize((128, 128)),
    transforms.ToTensor()
])

dataset = datasets.ImageFolder(
    root=os.path.join(DATA_DIR, "train"),
    transform=transform
)

loader = DataLoader(
    dataset,
    batch_size=16,
    shuffle=True
)

images, labels = next(iter(loader))

print("Image batch shape:", images.shape)
print("Label shape:", labels.shape)
print("Classes:", dataset.classes)

plt.figure(figsize=(12, 8))

for i in range(16):
    plt.subplot(4, 4, i + 1)
    plt.imshow(images[i].squeeze(0), cmap="gray")
    plt.title(dataset.classes[labels[i].item()])
    plt.axis("off")

plt.tight_layout()
plt.show()