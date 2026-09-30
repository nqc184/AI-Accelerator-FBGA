`timescale 1ns/1ps

module bias_adder #(
    parameter DATA_WIDTH = 48
)(
    input                           clk,
    input                           rst,
    input                           en,

    input                           valid_in,
    input      signed [DATA_WIDTH-1:0] data_in,
    input      signed [DATA_WIDTH-1:0] bias,

    output reg signed [DATA_WIDTH-1:0] data_out,
    output reg                      valid_out
);

always @(posedge clk or posedge rst) begin
    if(rst) begin
        data_out  <= 'sd0;
        valid_out <= 1'b0;
    end
    else begin
        valid_out <= 1'b0;

        if(en && valid_in) begin
            data_out  <= data_in + bias;
            valid_out <= 1'b1;
        end
    end
end

endmodule