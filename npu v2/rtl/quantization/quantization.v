module quantization #(
    parameter DATA_IN_WIDTH = 48,
    parameter DATA_OUT_WIDTH = 24
)(
    input wire clk,
    input wire rst,
    input wire en,
    input wire [1:0] mode_quantization, 
    input wire valid_in,
    input wire signed [DATA_IN_WIDTH-1:0] data_in,

    output wire signed [DATA_OUT_WIDTH-1:0] data_out,
    output wire valid_out
);

Round_to_Nearest #(
    .DATA_IN_WIDTH(DATA_IN_WIDTH),
    .DATA_OUT_WIDTH(DATA_OUT_WIDTH)
) round_inst (
    .clk(clk),
    .rst(rst),
    .en(en),
    .valid_in(valid_in),
    .data_in(data_in),
    .data_out(data_out),
    .valid_out(valid_out)
);
   
endmodule

