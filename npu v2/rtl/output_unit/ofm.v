`timescale 1ns/1ps

module ofm #(
    parameter DATA_WIDTH = 24,
    parameter MAX_IMG_WIDTH = 128,
    parameter MAX_KERNELS = 128
)(
    input wire clk,
    input wire rst,

    input wire [DATA_WIDTH-1:0] data_in0,
    input wire [DATA_WIDTH-1:0] data_in1,
    input wire [DATA_WIDTH-1:0] data_in2,
    input wire [DATA_WIDTH-1:0] data_in3,
    input wire [DATA_WIDTH-1:0] data_in4,

    input wire valid_in0,
    input wire valid_in1,
    input wire valid_in2,
    input wire valid_in3,
    input wire valid_in4,

    input wire config_start,
    input wire [15:0] img_width,
    input wire [15:0] img_height,
    input wire [15:0] num_kernels,

    output reg config_done,
    output reg write_done,

    input wire read_start,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg valid_out,
    output reg [$clog2(MAX_KERNELS)-1:0] kernel_out,
    output reg [31:0] addr_out,
    output reg read_done,
    output reg overflow
);

    localparam MEM_DEPTH = MAX_IMG_WIDTH * MAX_IMG_WIDTH * ((MAX_KERNELS + 4) / 5);

    reg [DATA_WIDTH-1:0] mem0 [0:MEM_DEPTH-1];
    reg [DATA_WIDTH-1:0] mem1 [0:MEM_DEPTH-1];
    reg [DATA_WIDTH-1:0] mem2 [0:MEM_DEPTH-1];
    reg [DATA_WIDTH-1:0] mem3 [0:MEM_DEPTH-1];
    reg [DATA_WIDTH-1:0] mem4 [0:MEM_DEPTH-1];

    reg [31:0] bank_count [0:4];
    reg [31:0] required_count [0:4];

    reg [15:0] cfg_kernels;
    reg [31:0] pixels_per_kernel;

    reg configured;
    reg reading;
    reg write_complete;

    reg [31:0] read_kernel;
    reg [31:0] read_addr;
    reg [31:0] bank_addr;

    reg [DATA_WIDTH-1:0] lane_data [0:4];
    reg [4:0] valid_vec;

    wire [31:0] count_after0;
    wire [31:0] count_after1;
    wire [31:0] count_after2;
    wire [31:0] count_after3;
    wire [31:0] count_after4;

    integer i;
    integer lane;

    always @* begin
        lane_data[0] = data_in0;
        lane_data[1] = data_in1;
        lane_data[2] = data_in2;
        lane_data[3] = data_in3;
        lane_data[4] = data_in4;

        valid_vec = {
            valid_in4,
            valid_in3,
            valid_in2,
            valid_in1,
            valid_in0
        };
    end

    assign count_after0 = bank_count[0] +
        ((valid_vec[0] &&
          bank_count[0] < required_count[0] &&
          bank_count[0] < MEM_DEPTH) ? 32'd1 : 32'd0);

    assign count_after1 = bank_count[1] +
        ((valid_vec[1] &&
          bank_count[1] < required_count[1] &&
          bank_count[1] < MEM_DEPTH) ? 32'd1 : 32'd0);

    assign count_after2 = bank_count[2] +
        ((valid_vec[2] &&
          bank_count[2] < required_count[2] &&
          bank_count[2] < MEM_DEPTH) ? 32'd1 : 32'd0);

    assign count_after3 = bank_count[3] +
        ((valid_vec[3] &&
          bank_count[3] < required_count[3] &&
          bank_count[3] < MEM_DEPTH) ? 32'd1 : 32'd0);

    assign count_after4 = bank_count[4] +
        ((valid_vec[4] &&
          bank_count[4] < required_count[4] &&
          bank_count[4] < MEM_DEPTH) ? 32'd1 : 32'd0);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cfg_kernels <= 0;
            pixels_per_kernel <= 0;

            configured <= 0;
            reading <= 0;
            write_complete <= 0;

            config_done <= 0;
            write_done <= 0;

            data_out <= 0;
            valid_out <= 0;
            kernel_out <= 0;
            addr_out <= 0;
            read_done <= 0;

            read_kernel <= 0;
            read_addr <= 0;
            bank_addr <= 0;

            overflow <= 0;

            for (i = 0; i < 5; i = i + 1) begin
                bank_count[i] <= 0;
                required_count[i] <= 0;
            end

        end else begin
            config_done <= 0;
            write_done <= 0;
            valid_out <= 0;
            read_done <= 0;

            if (config_start && !configured) begin
                if (img_width > 0 &&
                    img_height > 0 &&
                    num_kernels > 0 &&
                    num_kernels <= MAX_KERNELS &&
                    img_width <= MAX_IMG_WIDTH &&
                    ({16'b0, img_width} * {16'b0, img_height})
                        <= MEM_DEPTH) begin

                    cfg_kernels <= num_kernels;

                    pixels_per_kernel <=
                        {16'b0, img_width} * {16'b0, img_height};

                    configured <= 1;
                    config_done <= 1;
                    write_complete <= 0;

                    for (i = 0; i < 5; i = i + 1) begin
                        bank_count[i] <= 0;

                        if (num_kernels > i) begin
                            required_count[i] <=
                                (((num_kernels - 1 - i) / 5) + 1)
                                * ({16'b0, img_width}
                                * {16'b0, img_height});
                        end else begin
                            required_count[i] <= 0;
                        end
                    end

                end else begin
                    overflow <= 1;
                end
            end

            if (configured && !reading && !write_complete) begin
                for (lane = 0; lane < 5; lane = lane + 1) begin
                    if (valid_vec[lane]) begin
                        if (bank_count[lane] < required_count[lane] &&
                            bank_count[lane] < MEM_DEPTH) begin

                            case (lane)
                                0: mem0[bank_count[0]] <= lane_data[0];
                                1: mem1[bank_count[1]] <= lane_data[1];
                                2: mem2[bank_count[2]] <= lane_data[2];
                                3: mem3[bank_count[3]] <= lane_data[3];
                                4: mem4[bank_count[4]] <= lane_data[4];
                            endcase

                            bank_count[lane] <= bank_count[lane] + 1'b1;

                        end else if (required_count[lane] != 0) begin
                            overflow <= 1;
                        end
                    end
                end

                if (count_after0 >= required_count[0] &&
                    count_after1 >= required_count[1] &&
                    count_after2 >= required_count[2] &&
                    count_after3 >= required_count[3] &&
                    count_after4 >= required_count[4]) begin

                    write_done <= 1;
                    write_complete <= 1;
                end
            end

            if (read_start && configured &&
                write_complete && !reading) begin

                reading <= 1;
                read_kernel <= 0;
                read_addr <= 0;

            end else if (reading) begin
                if (read_kernel < cfg_kernels) begin
                    if (read_addr < pixels_per_kernel) begin

                        bank_addr =
                            (read_kernel / 5) * pixels_per_kernel
                            + read_addr;

                        case (read_kernel % 5)
                            0: data_out <= mem0[bank_addr];
                            1: data_out <= mem1[bank_addr];
                            2: data_out <= mem2[bank_addr];
                            3: data_out <= mem3[bank_addr];
                            4: data_out <= mem4[bank_addr];
                        endcase

                        valid_out <= 1;
                        kernel_out <= read_kernel;
                        addr_out <= read_addr;

                        read_addr <= read_addr + 1'b1;

                    end else begin
                        read_kernel <= read_kernel + 1'b1;
                        read_addr <= 0;
                    end

                end else begin
                    reading <= 0;
                    read_done <= 1;
                end
            end
        end
    end

endmodule