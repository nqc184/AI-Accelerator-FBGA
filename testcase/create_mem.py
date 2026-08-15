with open("IFM.mem", "w") as f:
    for i in range(1024):
        f.write(f"{i:06X}\n")