`timescale 1ns/1ps

module pe(
    input wire clk,
    input wire reset,
    input wire clear,
    input wire valid_in,
    input wire [15:0] in_a,
    input wire [15:0] in_b,
    output reg valid_out,
    output reg [15:0] out_a,
    output reg [15:0] out_b,
    output reg [15:0] out_c
);

    wire [15:0] mult_result;
    wire [15:0] add_result;

    fp16_multiplier u_multiplier(
        .a(in_a),
        .b(in_b),
        .result(mult_result)
    );

    fp16_adder u_adder(
        .a(out_c),
        .b(mult_result),
        .result(add_result)
    );

    always @(posedge clk) begin
        if (reset || clear) begin
            out_a <= 16'd0;
            out_b <= 16'd0;
            out_c <= 16'd0;
            valid_out <= 1'b0;
        end
        else begin
            valid_out <= valid_in;

            if (valid_in) begin
                out_a <= in_a;
                out_b <= in_b;
                out_c <= add_result;
            end
        end
    end

endmodule