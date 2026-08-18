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

    fp16_multiplier u_multiplier(
        .a(in_a),
        .b(in_b),
        .result(mult_result)
    );

    reg [15:0] mult_result_reg; 
    reg [15:0] in_a_reg, in_b_reg;
    reg        valid_stage1;

    always @(posedge clk) begin
        if (reset || clear) begin
            mult_result_reg <= 16'd0;
            in_a_reg        <= 16'd0;
            in_b_reg        <= 16'd0;
            valid_stage1    <= 1'b0;
        end
        else begin
            mult_result_reg <= mult_result;
            in_a_reg        <= in_a;
            in_b_reg        <= in_b;
            valid_stage1    <= valid_in;
        end
    end

    wire [15:0] add_result;

    fp16_adder u_adder(
        .a(out_c),             
        .b(mult_result_reg),   
        .result(add_result)
    );

    always @(posedge clk) begin
        if (reset || clear) begin
            out_a     <= 16'd0;
            out_b     <= 16'd0;
            out_c     <= 16'd0;
            valid_out <= 1'b0;
        end
        else begin
            valid_out <= valid_stage1;

            if (valid_stage1) begin
                out_a <= in_a_reg;
                out_b <= in_b_reg;
                out_c <= add_result;
            end
        end
    end

endmodule