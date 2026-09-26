#include <iostream>
#include <vector>
#include <iomanip>

using namespace std;

int main() {
    int ifm_h, ifm_w;

    cout << "===== INPUT FEATURE MAP =====\n";
    cout << "Nhap chieu cao IFM: ";
    cin >> ifm_h;
    cout << "Nhap chieu rong IFM: ";
    cin >> ifm_w;

    vector<vector<int>> ifm(ifm_h, vector<int>(ifm_w));

    cout << "\nNhap cac phan tu IFM:\n";
    for (int i = 0; i < ifm_h; i++) {
        for (int j = 0; j < ifm_w; j++) {
            cout << "IFM[" << i << "][" << j << "] = ";
            cin >> ifm[i][j];
        }
    }

    int kernel_size;
    int num_kernels;

    cout << "\n===== KERNEL =====\n";
    cout << "Nhap kich thuoc kernel K: ";
    cin >> kernel_size;
    cout << "Nhap so bo kernel: ";
    cin >> num_kernels;

    vector<vector<vector<int>>> weights(
        num_kernels,
        vector<vector<int>>(
            kernel_size,
            vector<int>(kernel_size)
        )
    );

    for (int k = 0; k < num_kernels; k++) {
        cout << "\n--- KERNEL " << k << " ---\n";
        for (int i = 0; i < kernel_size; i++) {
            for (int j = 0; j < kernel_size; j++) {
                cout << "W[" << k << "]["
                    << i << "]["
                     << j << "] = ";
                cin >> weights[k][i][j];
            }
        }
    }

    vector<int> bias(num_kernels);

    cout << "\n===== BIAS =====\n";

    for (int k = 0; k < num_kernels; k++) {
        cout << "Bias[" << k << "] = ";
        cin >> bias[k];
    }

    int stride;

    cout << "\n===== STRIDE =====\n";
    cout << "Nhap stride: ";
    cin >> stride;

    int padding;

    cout << "\n===== PADDING =====\n";
    cout << "Nhap padding: ";
    cin >> padding;

    int out_h = (ifm_h + 2 * padding - kernel_size) / stride + 1;
    int out_w = (ifm_w + 2 * padding - kernel_size) / stride + 1;

    if (out_h <= 0 || out_w <= 0) {
        cout << "\nERROR: Output size khong hop le!\n";
        return 1;
    }

    cout << "\n====================================\n";
    cout << "OUTPUT SIZE: " << out_h << " x " << out_w << "\n";
    cout << "SO OUTPUT CHANNEL: " << num_kernels << "\n";
    cout << "====================================\n";

    vector<vector<vector<long long>>> output(
        num_kernels,
        vector<vector<long long>>(
            out_h,
            vector<long long>(out_w, 0)
        )
    );

    for (int k = 0; k < num_kernels; k++) {
        for (int out_i = 0; out_i < out_h; out_i++) {
            for (int out_j = 0; out_j < out_w; out_j++) {
                long long sum = 0;
                for (int ki = 0; ki < kernel_size; ki++) {
                    for (int kj = 0; kj < kernel_size; kj++) {
                        int ifm_i = out_i * stride + ki - padding;
                        int ifm_j = out_j * stride + kj - padding;
                        int ifm_value = 0;
                        if (ifm_i >= 0 && ifm_i < ifm_h &&
                            ifm_j >= 0 && ifm_j < ifm_w) {
                            ifm_value = ifm[ifm_i][ifm_j];
                        }

                        int weight = weights[k][ki][kj];

                        sum += (long long)ifm_value * weight;
                    }
                }
                sum += bias[k];
                output[k][out_i][out_j] = sum;
            }
        }
    }

    cout << "\n\n====================================\n";
    cout << "CONVOLUTION RESULT\n";
    cout << "====================================\n";

    for (int k = 0; k < num_kernels; k++) {
        cout << "\nOUTPUT CHANNEL " << k << ":\n\n";
        for (int i = 0; i < out_h; i++) {
            for (int j = 0; j < out_w; j++) {
                cout << setw(8) << output[k][i][j] << " ";
            }
            cout << "\n";
        }
    }

    cout << "\n\n====================================\n";
    cout << "DETAILED CALCULATION\n";
    cout << "====================================\n";

    for (int k = 0; k < num_kernels; k++) {
        cout << "\n===== OUTPUT CHANNEL " << k << " =====\n";
        for (int out_i = 0; out_i < out_h; out_i++) {
            for (int out_j = 0; out_j < out_w; out_j++) {
                long long mac = 0;
                cout << "\nOutput[" << out_i << "][" << out_j << "]\n";
                cout << "MAC = ";
                bool first = true;
                for (int ki = 0; ki < kernel_size; ki++) {
                    for (int kj = 0; kj < kernel_size; kj++) {
                        int ifm_i = out_i * stride + ki - padding;
                        int ifm_j = out_j * stride + kj - padding;
                        int ifm_value = 0;
                        if (ifm_i >= 0 && ifm_i < ifm_h &&
                            ifm_j >= 0 && ifm_j < ifm_w) {
                            ifm_value = ifm[ifm_i][ifm_j];
                        }
                        int weight = weights[k][ki][kj];
                        int product = ifm_value * weight;
                        mac += product;
                        if (!first) {
                            cout << " + ";
                        }
                        cout << "(" << ifm_value << "*" << weight << ")";
                        first = false;
                    }
                }
                cout << "\nMAC = " << mac;
                cout << "\nBias = " << bias[k];
                cout << "\nResult = " << mac << " + " << bias[k] << " = " << output[k][out_i][out_j] << "\n";
            }
        }
    }
    return 0;
}
