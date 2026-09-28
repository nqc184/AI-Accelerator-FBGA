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
        .clk(), .rst(),
        .en(),
        .valid_in(),
        .data_in(),
        .data_out(),
        .valid_out()
    );

    Round_to_Nearest #(
        .DATA_IN_WIDTH(DATA_IN_WIDTH),
        .DATA_OUT_WIDTH(DATA_OUT_WIDTH)
    ) round_to_nearest_inst1 (
        .clk(), .rst(),
        .en(),
        .valid_in(),
        .data_in(),
        .data_out(),
        .valid_out()
    );

    Round_to_Nearest #(
        .DATA_IN_WIDTH(DATA_IN_WIDTH),
        .DATA_OUT_WIDTH(DATA_OUT_WIDTH)
    ) round_to_nearest_inst2 (
        .clk(), .rst(),
        .en(),
        .valid_in(),
        .data_in(),
        .data_out(),
        .valid_out()
    );

    Round_to_Nearest #(
        .DATA_IN_WIDTH(DATA_IN_WIDTH),
        .DATA_OUT_WIDTH(DATA_OUT_WIDTH)
    ) round_to_nearest_inst3 (
        .clk(), .rst(),
        .en(),
        .valid_in(),
        .data_in(),
        .data_out(),
        .valid_out()
    );

    Round_to_Nearest #(
        .DATA_IN_WIDTH(DATA_IN_WIDTH),
        .DATA_OUT_WIDTH(DATA_OUT_WIDTH)
    ) round_to_nearest_inst4 (
        .clk(), .rst(),
        .en(),
        .valid_in(),
        .data_in(),
        .data_out(),
        .valid_out()
    );
endmodule