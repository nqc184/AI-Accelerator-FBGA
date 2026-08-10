`timescale 1ns / 1ps
module pe (
    input wire clk,
    input wire reset,
    input wire clear,
    input wire signed [23:0] in_a,
    input wire signed [23:0] in_b,
    output reg signed [23:0] out_a,
    output reg signed [23:0] out_b,
    output reg signed [47:0] out_c
);

    always @(posedge clk) begin
        if (reset || clear) begin
            out_a <= 24'd0;
            out_b <= 24'd0;
            out_c <= 48'd0;
        end else begin
            out_a <= in_a;
            out_b <= in_b;
            out_c <= out_c + (in_a * in_b); 
        end
    end

endmodule