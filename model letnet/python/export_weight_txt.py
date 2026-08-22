import torch
import os
import numpy as np

state_dict = torch.load(
    "lenet_cat_dog.pth",
    map_location="cpu"
)

def export_conv_layer(weight, bias, folder_name):

    os.makedirs(folder_name, exist_ok=True)

    weight = weight.detach().cpu().numpy()
    bias = bias.detach().cpu().numpy()

    out_channels = weight.shape[0]
    in_channels = weight.shape[1]
    kernel_h = weight.shape[2]
    kernel_w = weight.shape[3]

    print(f"\nExport: {folder_name}")
    print("Weight shape:", weight.shape)

    for oc in range(out_channels):

        filename = os.path.join(
            folder_name,
            f"kernel_{oc}.txt"
        )

        with open(filename, "w") as f:

            for ic in range(in_channels):

                f.write(
                    f"Input Channel {ic}\n"
                )

                for ky in range(kernel_h):

                    for kx in range(kernel_w):

                        value = weight[
                            oc
                        ][
                            ic
                        ][
                            ky
                        ][
                            kx
                        ]

                        f.write(
                            f"{value:.8f} "
                        )

                    f.write("\n")

                f.write("\n")

        print("Saved:", filename)

    bias_file = os.path.join(
        folder_name,
        "bias.txt"
    )

    np.savetxt(
        bias_file,
        bias,
        fmt="%.8f"
    )

    print("Saved:", bias_file)


export_conv_layer(
    state_dict["conv1.weight"],
    state_dict["conv1.bias"],
    "weights/conv1"
)

export_conv_layer(
    state_dict["conv2.weight"],
    state_dict["conv2.bias"],
    "weights/conv2"
)

print("\nExport completed!")