`timescale 1ns/1ps
module ofm_lane #(
    parameter DW   = 24,
    parameter AW   = 16,
    parameter LANE = 0
)(
    input wire clk, rst, batch_start,
    input wire [2:0] lane_count,
    input wire [2:0] win_in_batch,
    input wire [AW-1:0] base_addr,
    input wire signed [DW-1:0] din,
    input wire dvalid,

    output reg wr_en,
    output reg [AW-1:0] wr_addr,
    output reg signed [DW-1:0] wr_data
);
    reg [2:0] n;
    reg [AW-1:0] base_q;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            n <= 3'd0;
            wr_en <= 1'b0;
            base_q <= {AW{1'b0}};
            wr_addr <= {AW{1'b0}};
            wr_data <= {DW{1'b0}};
        end
        else if (batch_start) begin
            n <= 3'd0;
            wr_en <= 1'b0;
            base_q <= base_addr;
        end
        else begin
            wr_en <= dvalid && (LANE < lane_count) && (n < win_in_batch);
            wr_addr <= base_q + n;
            wr_data <= din;
            if (dvalid) n <= n + 3'd1;
        end
    end
endmodule