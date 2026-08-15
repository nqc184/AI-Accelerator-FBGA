from PIL import Image
import torchvision.transforms as transforms
import torch
import torch.nn as nn
import matplotlib.pyplot as plt
import numpy as np
import os


# ==================================================
# 1. Cố định random để kernel không thay đổi
# ==================================================

torch.manual_seed(0)



# ==================================================
# 2. Tạo Conv1 giống LeNet
# ==================================================

conv1 = nn.Conv2d(
    in_channels=1,
    out_channels=6,
    kernel_size=5,
    stride=1,
    padding=0
)



# ==================================================
# 3. Đọc ảnh
# ==================================================

img = Image.open("images.jpg")


print("Ảnh gốc:")
print(img.size)



# ==================================================
# 4. Chuyển grayscale
# ==================================================

img_gray = img.convert("L")



# ==================================================
# 5. Resize 32x32
# ==================================================

img_gray = img_gray.resize((32,32))


print("Ảnh sau resize:")
print(img_gray.size)



# ==================================================
# 6. Convert ảnh sang tensor
# ==================================================

transform = transforms.ToTensor()

img_tensor = transform(img_gray)


# trước:
# [1,32,32]

# thêm batch:
img_tensor = img_tensor.unsqueeze(0)


print("\nIFM shape:")
print(img_tensor.shape)



# ==================================================
# 7. Chạy Conv1
# ==================================================

output = conv1(img_tensor)


print("\nOFM shape:")
print(output.shape)



# ==================================================
# 8. Tạo thư mục lưu dữ liệu
# ==================================================

os.makedirs("DATA/IFM", exist_ok=True)
os.makedirs("DATA/KERNEL", exist_ok=True)
os.makedirs("DATA/OFM", exist_ok=True)
os.makedirs("DATA/OFM_IMAGE", exist_ok=True)



# ==================================================
# 9. Xuất IFM 32x32
# ==================================================

ifm = img_tensor[0,0,:,:].detach().numpy()


np.savetxt(
    "DATA/IFM/ifm.txt",
    ifm,
    fmt="%.8f"
)


print("\nIFM đã lưu")



# ==================================================
# 10. Xuất Kernel 6 bộ 5x5
# ==================================================

weight = conv1.weight.detach().numpy()


for i in range(6):

    kernel = weight[i,0,:,:]


    np.savetxt(
        f"DATA/KERNEL/kernel_{i}.txt",
        kernel,
        fmt="%.8f"
    )


print("Kernel đã lưu")



# ==================================================
# 11. Xuất OFM 6 feature map
# ==================================================

ofm_all = output.detach().numpy()


for i in range(6):

    feature_map = ofm_all[0,i,:,:]


    np.savetxt(
        f"DATA/OFM/output_{i}.txt",
        feature_map,
        fmt="%.8f"
    )


print("OFM đã lưu")



# ==================================================
# 12. In kiểm tra pixel đầu tiên
# ==================================================

print("\n===== KIỂM TRA OFM =====")


for i in range(6):

    feature_map = output[0,i,:,:].detach().numpy()


    print("-------------------")
    print("OFM:",i)
    print("Shape:",feature_map.shape)

    print(
        "Pixel đầu tiên:",
        feature_map[0][0]
    )



# ==================================================
# 13. Vẽ 6 OFM thành ảnh
# ==================================================

plt.figure(figsize=(10,6))


for i in range(6):

    feature_map = output[0,i,:,:].detach().numpy()


    # lưu ảnh
    plt.imsave(
        f"DATA/OFM_IMAGE/OFM_{i}.png",
        feature_map,
        cmap="gray"
    )


    # hiển thị

    plt.subplot(2,3,i+1)

    plt.imshow(
        feature_map,
        cmap="gray"
    )

    plt.title(
        f"OFM {i}"
    )

    plt.axis("off")


plt.tight_layout()

plt.show()



# ==================================================
# 14. In kernel đầu tiên
# ==================================================

print("\n===== KERNEL 0 =====")

print(
    conv1.weight[0,0,:,:]
)

print(conv1.bias)