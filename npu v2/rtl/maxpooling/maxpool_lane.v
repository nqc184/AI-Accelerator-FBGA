`timescale 1ns/1ps
module maxpool_lane #(
    parameter DW = 24,
    parameter MAX_W = 128,
    parameter P = 3
)(
    input wire clk, rst,
    input wire start_layer,
    input wire [15:0] out_w, out_h,
    input wire [2:0] pool_size,
    input wire [2:0] pool_stride,
    input wire pool_enable,

    input wire signed [DW-1:0] din,
    input wire dvalid,

    output reg signed [DW-1:0] dout,
    output reg dvalid_out
);
    reg [15:0] col, row;
    reg [2:0] reg_pool_size, reg_pool_stride;

    reg signed [DW-1:0] line_buf [0:P-2][0:MAX_W-1];
    reg signed [DW-1:0] win [0:P-1][0:P-1];

    integer r, c;

    wire [15:0] k1 = reg_pool_size - 16'd1;
    wire is_pool_row = (row >= k1) && (row % reg_pool_stride == k1 % reg_pool_stride);
    wire is_pool_col = (col >= k1) && (col % reg_pool_stride == k1 % reg_pool_stride);

    reg signed [DW-1:0] max_val;
    always @(*) begin
        max_val = win[0][0];
        for (r = 0; r < P; r = r + 1)
            for (c = 0; c < P; c = c + 1)
                if (r < reg_pool_size && c < reg_pool_size && win[r][c] > max_val)
                    max_val = win[r][c];
    end

    reg pool_hit;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            col <= 0; row <= 0; dvalid_out <= 0; dout <= 0; pool_hit <= 0;
            reg_pool_size <= 3'd2; reg_pool_stride <= 3'd2;
        end
        else if (start_layer) begin
            col <= 0; row <= 0; dvalid_out <= 0; pool_hit <= 0;
            reg_pool_size   <= pool_size;
            reg_pool_stride <= pool_stride;
        end
        else if (!pool_enable) begin
            dout <= din;
            dvalid_out <= dvalid;
            if (dvalid) begin
                if (col == out_w-1) begin col <= 0; row <= (row==out_h-1)?0:row+1; end
                else col <= col + 1;
            end
        end
        else if (dvalid) begin
            line_buf[0][col] <= din;
            for (r = 1; r < P-1; r = r + 1)
                line_buf[r][col] <= line_buf[r-1][col];
            win[0][0] <= din;
            for (c = 1; c < P; c = c + 1)
                win[0][c] <= win[0][c-1];
            for (r = 1; r < P; r = r + 1) begin
                win[r][0] <= line_buf[r-1][col];
                for (c = 1; c < P; c = c + 1)
                    win[r][c] <= win[r][c-1];
            end
            if (col == out_w-1) begin
                col <= 0;
                row <= (row == out_h-1) ? 0 : row+1;
            end
            else col <= col + 1;
            dout       <= max_val;
            pool_hit   <= is_pool_row && is_pool_col;
            dvalid_out <= pool_hit;
        end
        else begin
            dvalid_out <= 0;
        end
    end
endmodule