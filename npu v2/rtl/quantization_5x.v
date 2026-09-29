module quantization_5x #(
    parameter DATA_IN_WIDTH = 48,
    parameter DATA_OUT_WIDTH = 24
)(
    input wire clk, rst,
    input wire en0, en1, en2, en3, en4, 
    input wire valid_in0, valid_in1, valid_in2, valid_in3, valid_in4,
    input wire signed [DATA_IN_WIDTH-1:0] data_in0, data_in1, data_in2, data_in3, data_in4,
    output wire signed [DATA_OUT_WIDTH-1:0] data_out0, data_out1, data_out2, data_out3, data_out4,
    output wire valid_out0, valid_out1, valid_out2, valid_out3, valid_out4
);

    Round_to_Nearest #(
        .DATA_IN_WIDTH(DATA_IN_WIDTH),
        .DATA_OUT_WIDTH(DATA_OUT_WIDTH)
    ) round_to_nearest_inst0 (
        .clk(clk), .rst(rst),
        .en(en0),
        .valid_in(valid_in0),
        .data_in(data_in0),
        .data_out(data_out0),
        .valid_out(valid_out0)
    );

    Round_to_Nearest #(
        .DATA_IN_WIDTH(DATA_IN_WIDTH),
        .DATA_OUT_WIDTH(DATA_OUT_WIDTH)
    ) round_to_nearest_inst1 (
        .clk(clk), .rst(rst),
        .en(en1),
        .valid_in(valid_in1),
        .data_in(data_in1),
        .data_out(data_out1),
        .valid_out(valid_out1)
    );

    Round_to_Nearest #(
        .DATA_IN_WIDTH(DATA_IN_WIDTH),
        .DATA_OUT_WIDTH(DATA_OUT_WIDTH)
    ) round_to_nearest_inst2 (
        .clk(clk), .rst(rst),
        .en(en2),
        .valid_in(valid_in2),
        .data_in(data_in2),
        .data_out(data_out2),
        .valid_out(valid_out2)
    );

    Round_to_Nearest #(
        .DATA_IN_WIDTH(DATA_IN_WIDTH),
        .DATA_OUT_WIDTH(DATA_OUT_WIDTH)
    ) round_to_nearest_inst3 (
        .clk(clk), .rst(rst),
        .en(en3),
        .valid_in(valid_in3),
        .data_in(data_in3),
        .data_out(data_out3),
        .valid_out(valid_out3)
    );

    Round_to_Nearest #(
        .DATA_IN_WIDTH(DATA_IN_WIDTH),
        .DATA_OUT_WIDTH(DATA_OUT_WIDTH)
    ) round_to_nearest_inst4 (
        .clk(clk), .rst(rst),
        .en(en4),
        .valid_in(valid_in4),
        .data_in(data_in4),
        .data_out(data_out4),
        .valid_out(valid_out4)
    );
endmodule